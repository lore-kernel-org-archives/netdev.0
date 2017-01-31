From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: allow TTL propagation to/from IP packets to be configured
Date: Tue, 31 Jan 2017 13:17:07 +1300
Message-ID: <878tpst75o.fsf@xmission.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41701 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753576AbdAaAWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 19:22:30 -0500
In-Reply-To: <1485808575-16852-1-git-send-email-rshearma@brocade.com> (Robert
        Shearman's message of "Mon, 30 Jan 2017 20:36:15 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> It is sometimes desirable to present an MPLS transport network as a
> single hop to traffic transiting it because it prevents confusion when
> diagnosing failures. An example of where confusion can be generated is
> when addresses used in the provider network overlap with addresses in
> the overlay network and the addresses get exposed through ICMP errors
> generated as packets transit the provider network.
>
> Therefore, provide the ability to control whether the TTL value from
> an MPLS packet is propagated to an IPv4/IPv6 packet when the last
> label is popped through the addition of a new per-namespace sysctl:
> "net.mpls.ip_ttl_propagate" which defaults to enabled.
>
> Use the same sysctl to control whether the TTL is propagated from IP
> packets into the MPLS header. If the TTL isn't propagated then a
> default TTL value is used which can be configured via a new sysctl:
> "net.mpls.default_ttl".

Instead of having a global sysctl can we please have a different way
to configure the ingress/egress?

My general memory is that this makes sense for a slightly different
tunnel type.   Making it a per mpls tunnel property instead of global
property feels like it should be much more maintainable.

Similarly with the related behavior of what to do if the mpls ttl is
exhausted during the trip through the tunnel.  Drop or dig through the
packet and send an ICMP error message at the ip layer.

Eric
