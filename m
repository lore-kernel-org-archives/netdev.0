From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 0/3] secid reconciliation-v01: Repost patchset with up
	 dates
Date: Thu, 31 Aug 2006 11:13:23 -0400
Message-ID: <36282A1733C57546BE392885C061859201512B91@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, Stephen Smalley <sds@tycho.nsa.gov>,
	Chad Hanson <chanson@TrustedCS.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:62323 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932346AbWHaPNl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 11:13:41 -0400
To: Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Assuming the permission is granted the packet's secmark is 
> replaced with
> the updated context.  This updated secmark context would then 
> be used in
> sock_rcv_skb() to make an access decision, yes?

You got it.

> 
> >> The ability to make access decisions based on the process
> >>consuming the data and the data itself it one of the nicer 
> >>qualities of
> >>NetLabel in my opinion.
> > 
> > This nicer quality ends up being preserved as explained above :)
> 
> It wasn't clear to me from your patch or the "master plan" what you
> intended to do with the NetLabel context.  I thought the "/* See if
> CIPSO can flow in thru the current secmark here */" comment in your
> patch was rather cryptic.

That was a test for you :)
> 
> > We just need to get out of the mindset of viewing netlabel 
> separately
> > once we are past the reconciliation point.
> 
> Agreed.  Although to be honest, I think the NetLabel context can be
> reconciled with the secmark and XFRM contexts just as easily using the
> existing sock_rcv_skb() hook.

Nope. That won't work for forwarded traffic.

>  I guess I need to see where the
> xfrm[4|6]_policy_check() hooks are called from in the stack to better
> understand ...

You are on the right path here.
