From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits
 ip command on 64bits host
Date: Tue, 25 Feb 2014 14:41:11 +0800
Message-ID: <530C3B07.3090406@windriver.com>
References: <1392801176-2656-1-git-send-email-fan.du@windriver.com> <20140220095934.GF32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63701 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaBYGlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 01:41:32 -0500
In-Reply-To: <20140220095934.GF32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B402=E6=9C=8820=E6=97=A5 17:59, Steffen Klassert wrote:
> For now I think we should just refuse to do anything if someone tries
> to configure ipsec with 32 bit tools on a 64 bit machine.

I'm fine with your point, and it would be a good choice to inform user =
about
this behavior other than just creating non-working SA and SP for user.


 From 873812ec0fe8738f476de58a217e58ec47665180 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Tue, 25 Feb 2014 14:34:41 +0800
Subject: [PATCH net-next] xfrm: Do not parse 32bits compiled xfrm netli=
nk msg on
  64bits host

structure like xfrm_usersa_info or xfrm_userpolicy_info has different s=
izeof
when compiled as 32bits and 64bits due to not appending pack attribute =
in
their definition. This will result in broken SA and SP information when=
 user
trying to configure them through netlink interface.

Before forging a compatibility layer like we have it for system calls t=
o map
this correct. Inform user land about this situation instead of keeping =
silent,
then the upper test scripts could behave accordingly.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
  net/xfrm/xfrm_user.c |    4 ++++
  1 file changed, 4 insertions(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1ae3ec7..0249712 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2347,6 +2347,10 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb=
, struct nlmsghdr *nlh)
  	const struct xfrm_link *link;
  	int type, err;

+#ifdef CONFIG_COMPAT
+	if (is_compat_task())
+		return -EPERM;
+#endif
  	type =3D nlh->nlmsg_type;
  	if (type > XFRM_MSG_MAX)
  		return -EINVAL;
--=20
1.7.9.5


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
