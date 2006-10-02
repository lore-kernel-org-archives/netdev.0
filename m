From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH v2 1/1] NetLabel: secid reconciliation support
Date: Mon, 2 Oct 2006 16:04:37 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF59C@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:48160 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S964943AbWJBUFJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 16:05:09 -0400
To: Paul Moore <paul.moore@hp.com>, Stephen Smalley <sds@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > If this selinux_netlbl_skb_sid() call can fail for any 
> reason other than
> > a kernel bug, then this needs to goto out instead of using 
> BUG_ON.  For
> > example, if the function can fail due to temporary memory pressure
> > leading to a failed allocation, then you want to simply 
> drop the packet,
> > not panic the kernel.  
> 
> That's fine - see the discussion Venkat and I had earlier.  
> I'll change
> it to jump to "out".

Just to clarify, my comments earlier about BUG_ON were in
relation to selinux_xfrm_decode_session which can only fail
as a result of a bug or kernel corruption. For "other" errors,
a jump out indeed seems proper, like you are already planning to do.
