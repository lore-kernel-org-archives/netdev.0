From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Sun, 1 Oct 2006 16:55:47 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF3C7@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:46169 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932369AbWJAU6N
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 16:58:13 -0400
To: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The way I was seeing the problem was when connecting via IPsec to a 
> confined service on an SELinux box (vsftpd), which did not have the 
> appropriate SELinux policy permissions to send packets via IPsec.
> 
> The first SYNACK would be blocked,

Given that the resolver fails to find a policy here, I am trying to
understand what exactly is blocking it (the first SYNACK) from
proceeding without IPSec.

> because of an uncached lookup via 
> flow_cache_lookup(), which would fail to resolve an xfrm 
> policy because 
> the SELinux policy is checked at that point via the resolver.
> 
> However, retransmitted SYNACKs would then find a cached flow 
> entry when 
> calling into flow_cache_lookup() with a null xfrm policy, which is 
> interpreted by xfrm_lookup() as the packet not having any associated 
> policy and similarly to the first case, allowing it to pass without 
> transformation.
