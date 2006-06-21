From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 01/06] MLSXFRM: Granular IPSec associations for use in
	 MLS environments
Date: Wed, 21 Jun 2006 16:36:12 -0400
Message-ID: <36282A1733C57546BE392885C06185920132419A@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:36707 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1030267AbWFUUgm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 16:36:42 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Can you clarify whether, with this patch, Linux will then 
> have a complete 
> labeled network implementation in terms of both LSPP 
> compliance and common 
> user requirements?

I can't comment on the LSPP compliance issue since the specific/proprietary
security target being used might really decide what's needed.

As for common user requirements, at least as I understand them, I would
look for the following in addition to this patch:

- Auto-labelling of child sockets for TCP (I am planning on sending a
separate
  patch out in the next few days).
- Using the label from the incoming packet while sending timewait
acknowledgements
  and other packets sent on behalf of kernel sockets.
- sid prioritization among the current mix of secmark, ipsec, and the
upcoming netlabel
- Replacing secmark on output with an access check in postrouting.
- localhost traffic handling with regard to labelling.

> 
> > Outstanding items/issues: 
> > - Timewait acknowledgements and such are generated in the 
> > current/upstream implementation using a NULL socket 
> resulting in the 
> > any_socket sid (SYSTEM_HIGH) to be used. This problem is 
> not addressed 
> > by this patch set.
> 
> This needs to be resolved, along with labeling for all kernel owned 
> socket/tw objects.

Resolved these should be, but given the fact that this patch doesn't
introduce this problem in the first place, and given the value it adds to
the
xfrm stuff, my hope would be for this patch to be treated separately. I am
hoping
for 2.6.18 if possible.

>  I'm not entirely clear on why this 
> doesn't already 
> work, as it is using IPsec, which should certainly be able to 
> encapsulate 
> all of this traffic.

Sans label-based checks, no problem. But with label-enhanced checks in
place,
we need to have the label to use, which we don't since there's no real
socket present which normally provided the label. One way to handle
this would be to use the label on the incoming packet for the response
as mentioned earlier.

> 
> It would also be interesting to know what kind of testing 
> this code as 
> had.

Primarily functional testing. Joy Latten at IBM is planning
on further testing this using the framework built for the original
work I believe.
