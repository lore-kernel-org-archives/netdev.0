From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/9] secid reconciliation-v04: Enforcement for SELinux
Date: Mon, 2 Oct 2006 13:25:34 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF4E4@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:18255 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S965156AbWJBR0K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 13:26:10 -0400
To: Paul Moore <paul.moore@hp.com>, Stephen Smalley <sds@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> My immediate concern is not really what selinux_xfrm_decode_session()
> returns, but how to handle it, or rather errors in general, in
> selinux_skb_flow_in().  I'm in the process of creating a patch to add
> the missing NetLabel support to the secid patches and I am 
> wondering if
> I should BUG_ON() for an error condition or simply jump to "out".
> Jumping seems a bit cleaner to me, although perhaps harder to 
> debug, so
> I was just wondering what the reasoning was behind the use of 
> BUG_ON().

It's more a "code integrity" check that I have sought to enforce
via BUG_ON (meaning the function isn't expected to fail under any
circumstances). Whether this is a severe enough error (possible as
a result of a bug in decode_session or a corrupted kernel) that we
should panic the system at that point is probably debatable. In particular
I would be interested to know how similar situations are currently
treated in the kernel.

My recommendation would be to be consistent with the rest of the code
and do a BUG_ON. As for other errors, you could jump out like the rest
of the code already does (if that meets your needs that is).
