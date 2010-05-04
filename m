From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 03 May 2010 23:42:54 -0700 (PDT)
Message-ID: <20100503.234254.150142339.davem@davemloft.net>
References: <AANLkTingTdmhyJhENb9AYDjUT7m_-yQflw5-gJqIA9iw@mail.gmail.com>
	<20100503.232249.200767273.davem@davemloft.net>
	<AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: enh@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755499Ab0EDGmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:42:49 -0400
In-Reply-To: <AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: enh <enh@google.com>
Date: Mon, 3 May 2010 23:27:23 -0700

> On Mon, May 3, 2010 at 23:22, David Miller <davem@davemloft.net> wrote:
>> Ok, I see, so yeah this needs to be fixed to use "1" instead of
>> "-1" in the np->xxx ipv6 socket initialization.
> 
> i think so. there's already the IPV6_DEFAULT_MCASTHOPS constant
> defined to 1 but unused according to gitweb, so you might want to
> either use it or remove it.

I've applied the following, thanks Elliot.

--------------------
ipv6: Fix default multicast hops setting.

As per RFC 3493 the default multicast hops setting
for a socket should be "1" just like ipv4.

Ironically we have a IPV6_DEFAULT_MCASTHOPS macro
it just wasn't being used.

Reported-by: Elliot Hughes <enh@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/af_inet6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3192aa0..3f9e86b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -200,7 +200,7 @@ lookup_protocol:
 
 	inet_sk(sk)->pinet6 = np = inet6_sk_generic(sk);
 	np->hop_limit	= -1;
-	np->mcast_hops	= -1;
+	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
 	np->ipv6only	= net->ipv6.sysctl.bindv6only;
-- 
1.7.0.4

