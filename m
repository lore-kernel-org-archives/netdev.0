From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 13:19:43 -0400
Message-ID: <OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com> <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:40609 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759723Ab3EORVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 13:21:17 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 15 May 2013 13:21:16 -0400
In-Reply-To: <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 05/15/2013 12:53:22 PM:

> From: Stephen Hemminger <stephen@networkplumber.org>
 
> No. I want all users to get the IANA assigned port unless they 
specifically
> override it. For compatibility kernel can't change to the IANA value
> but user space needs to nudge users in the correct direction.

It's more than a nudge -- it doesn't interoperate with itself.

1) The kernel binds to 8472 on module load.
2) After it's bound, iproute2 "changes" the port to 4789, but
        the kernel binding is still 8742 for listening. All destinations 
use
        the new port, but all bindings use the old port.

So, boot two systems without specifying a port and they can't
talk to each other. They both listen on 8742 and they both send to
4789.

This clearly is worse than changing the kernel default port to 4789, but
what's the point of having a kernel default if a user-level program 
overrides
it even when the user did not specify a port, and only for half of it (the
sender side)?

You could make a port change close and rebind, but that's little different
than changing the default in the kernel, if "ip" does it without a port
specification. 
                                                                +-DLS
