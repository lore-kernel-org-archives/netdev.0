From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] ipcomp: Convert struct xt_ipcomp spis into 16bits
Date: Mon, 20 Jan 2014 09:55:42 +0800
Message-ID: <52DC821E.3000309@windriver.com>
References: <1390011374-21760-1-git-send-email-fan.du@windriver.com> <20140118122437.GA4309@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45984 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbaATBzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 20:55:46 -0500
In-Reply-To: <20140118122437.GA4309@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B401=E6=9C=8818=E6=97=A5 20:24, Pablo Neira Ayuso wrote:
> On Sat, Jan 18, 2014 at 10:16:14AM +0800, Fan Du wrote:
>> >  sparse warnings: (new ones prefixed by>>)
>> >
>>>>>> >  >>  >>  net/netfilter/xt_ipcomp.c:63:26: sparse: restricted _=
_be16 degrades to integer
>>>>>> >  >>  >>  net/netfilter/xt_ipcomp.c:63:26: sparse: cast to rest=
ricted __be32
>> >
>> >  Fix this by using 16bits long spi, as IPcomp CPI is only valid fo=
r 16bits.
>> >
>> >  Signed-off-by: Fan Du<fan.du@windriver.com>
>> >  ---
>> >    include/uapi/linux/netfilter/xt_ipcomp.h |    2 +-
>> >    net/netfilter/xt_ipcomp.c                |    4 ++--
>> >    2 files changed, 3 insertions(+), 3 deletions(-)
>> >
>> >  diff --git a/include/uapi/linux/netfilter/xt_ipcomp.h b/include/u=
api/linux/netfilter/xt_ipcomp.h
>> >  index 45c7e40..ca82ebb 100644
>> >  --- a/include/uapi/linux/netfilter/xt_ipcomp.h
>> >  +++ b/include/uapi/linux/netfilter/xt_ipcomp.h
>> >  @@ -4,7 +4,7 @@
>> >    #include<linux/types.h>
>> >
>> >    struct xt_ipcomp {
>> >  -	__u32 spis[2];	/* Security Parameter Index */
>> >  +	__u16 spis[2];	/* Security Parameter Index */
> This changes the binary interface so it break userspace (iptables
> needs to be recompiled), we're still in time to make such change as
> this is net-next stuff, but what I understand from the patch
> description is that this aims to fix a sparse warning, which is a bit
> of intrusive change.
>
> Didn't you find any way to fix this without change the layout of
> xt_ipcomp?
>

My bad for not catching this in the initial ipcomp version.
It would be easier to just use ntohs here to ease sparse checking.


 From dbf796e63d600256fd40000669b83227ddccebc4 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Mon, 20 Jan 2014 09:42:12 +0800
Subject: [PATCHv2 net-next] ipcomp: Use ntohs to ease sparse warning

0-DAY kernel build testing backend reported:

sparse warnings: (new ones prefixed by >>)

 >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: restricted __be16 degra=
des to integer
 >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: cast to restricted __be=
32

=46ix this by using ntohs without shifting.

Tested with: make C=3D1 CF=3D-D__CHECK_ENDIAN__

Signed-off-by: Fan Du <fan.du@windriver.com>
---
  net/netfilter/xt_ipcomp.c |    2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_ipcomp.c b/net/netfilter/xt_ipcomp.c
index a4c7561..89d5310 100644
--- a/net/netfilter/xt_ipcomp.c
+++ b/net/netfilter/xt_ipcomp.c
@@ -60,7 +60,7 @@ static bool comp_mt(const struct sk_buff *skb, struct=
 xt_action_param *par)
  	}

  	return spi_match(compinfo->spis[0], compinfo->spis[1],
-			 ntohl(chdr->cpi << 16),
+			 ntohs(chdr->cpi),
  			 !!(compinfo->invflags & XT_IPCOMP_INV_SPI));
  }

--=20
1.7.9.5


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
