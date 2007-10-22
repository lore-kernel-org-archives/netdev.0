From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH] netdev: Reset ipv4 flags during bundle creation on interfamily ipsec
Date: Mon, 22 Oct 2007 09:55:53 +0300
Message-ID: <200710220955.53895.joakim.koskela@hiit.fi>
References: <E1IisnN-0003rh-00@gondolin.me.apana.org.au>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:55377 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750985AbXJVHBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 03:01:24 -0400
In-Reply-To: <E1IisnN-0003rh-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 October 2007 17:25:49 Herbert Xu wrote:
> Joakim Koskela <joakim.koskela@hiit.fi> wrote:
> > I'm not sure I follow. This affects the ipv6 bundling only where the
> > struct (fl_tunnel) has previously been used for ipv6 addresses. Not that
> > we are using the same block for holding the ipv4 info, the tos-value is
> > really undefined before we reset it.
>
> You're right.  But sure the same bug could affect IPv4 as well
> if you had a 4-6-4 configuration.  Let me think about this one
> a bit more.

Hi, and thanks for the feedback. True, this one affects only one level of 
inter-family, and supporting more would require a lot more changes in the 
bundle creation (perhaps combining both versions and taking better into 
account the outer family of the last transformation..). 

Another quite annoying example of this is that 6 in 4 actually crashes the 
kernel on 64 bit, as xfrm_dst_lookup around xfrm6_policy.c:197 changes rt 
from a rt6_info to a rtable. On 64 bit, rt->rt61i_node will usually contain 
something (due to the larger pointer size), making the path_cookie assignment 
on line 208 crash.

I've been trying address this in a proper manner, but it hasn't really 
progressed quite the way I've wanted (..thus this shallow patch, just to make 
6-4 inter-work in most cases on the standard kernel). Needless to say, any 
work done for this would be greatly appreciated :)

