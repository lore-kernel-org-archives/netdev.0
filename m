From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: RFC - VXLAN port range facility
Date: Thu, 30 May 2013 14:00:51 -0400
Message-ID: <OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com> <20130530094141.7c125947@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48083 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757308Ab3E3SGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 14:06:01 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 30 May 2013 12:05:58 -0600
In-Reply-To: <20130530094141.7c125947@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 05/30/2013 12:41:41 PM:

> From: Stephen Hemminger <stephen@networkplumber.org>
> 
> The source port is not related to what some application receives.
> A RFC conforming VXLAN endpoint will never send traffic back tot the
> senders source
> port. If VXLAN traffic got an ICMP response form an router like
> DESTINATION_UNREACHABLE there should be a match on destination port as 
well.

It'd be sent to the source port of the sender and it need not be bound to
a remote port -- for example, a netfilter rule blocking the destination
would send an administratively-prohibited ICMP error to a UDP
application that did not trigger the traffic that caused the error.

Quite simply, VXLAN uses UDP so it needs to follow the rules of UDP.

But I don't think there's particular advantage in splitting it up 30,000
ways when 10 ways would be both practical, for binding, and spread
traffic to 10 flows potentially.

> 
> Port ranges are critical to retaining scaling in multi-path 
infrastructure.
> Otherwise all traffic will arrive on a single queue in NIC.

I agree, but I don't think there need to be so many, and whatever
the VXLAN draft says, it can't  start causing problems for existing
UDP applications. VXLAN simply shouldn't be using ports allocated
to other applications; it can only do this because the implementation
is not using the real UDP stack to send the packets, but it still
should follow the rules  just as all other UDP servers must do. How
that's enforced is an implementation issue, but I think it must be
enforced.

I think it should be binding to all ports it uses as sources, and
the default range should be min and max of the bind port. People
who need to spread flows have the capability, but that doesn't mean
they need it on by default, or that it has to be so many, or that
it has carte blanche to interfere with existing UDP applications.

                                                                +-DLS
