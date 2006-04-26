From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 12:23:37 -0700 (PDT)
Message-ID: <20060426.122337.49702390.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AE16@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kelly@au1.ibm.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63174
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964846AbWDZTYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 15:24:00 -0400
To: caitlinb@broadcom.com
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143AE16@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Caitlin Bestler" <caitlinb@broadcom.com>
Date: Wed, 26 Apr 2006 09:57:22 -0700

> The major element I liked about Kelly's approach is that the ring
> is clearly designed to allow a NIC to place packets directly into
> a ring that is directly accessible by the user. Evolutionary steps
> are good, but isn't direct placement into a user-accessible simple
> ring buffer the ultimate justification of netchannels?

It is a very good point and one I actually need to think about
some more.

I'll be up front and say that I don't think it's actually necessary to
do channels all the way to userspace, just channeling to the in-kernel
networking protocol is more than sufficient.  This will get us most of
the way without having to deal with any of the thorny issues of doing
protocols in userspace.  I could be wrong but this is my gut instinct
at this time.

> Central integration also will need to be integrated with packet
> filtering.  In particular, once a flow has been assigned to a
> netchannel ring, who is responsible for doing the packet filtering?
> Or is it enough to check the packet filter when the net channel flow
> is created?

Very good question and one that hasn't been discussed enough yet.

Eventually we should be able to do things such as allow netfilter
to register channels too.

Before we do that, we'll have to decide how we'll handle potential
conflicts between local sockets and firewall rules.

There is a school of opinion that would agree to a rule such as:
if a local socket exists, it can trump firewalling.

This would be a nice and simple way to deal with firewall rules that
potentially shadow local sockets.  You couldn't have created that
fully bound socket in the first place if the firewall rules didn't
allow it.  You'd need to insert rules subsequently that block the
connection's flow.  If we want to support that we either have to do
netfilter channels from the get-go, or simply disable socket
netchannels altogether if netfilter is enabled.

I personally think allowing sockets to trump firewall rules is an
acceptable relaxation of the rules in order to simplify the
implementation.
