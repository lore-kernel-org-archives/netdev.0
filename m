From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: RFC - VXLAN port range facility
Date: Fri, 31 May 2013 09:13:38 -0700
Message-ID: <20130531091338.12fc7df5@nehalam.linuxnetplumber.net>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
	<20130530094141.7c125947@nehalam.linuxnetplumber.net>
	<OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:58343 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687Ab3EaQNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 12:13:42 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so2471290pbc.3
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 09:13:41 -0700 (PDT)
In-Reply-To: <OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 May 2013 14:00:51 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> netdev-owner@vger.kernel.org wrote on 05/30/2013 12:41:41 PM:
> 
> > From: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > The source port is not related to what some application receives.
> > A RFC conforming VXLAN endpoint will never send traffic back tot the
> > senders source
> > port. If VXLAN traffic got an ICMP response form an router like
> > DESTINATION_UNREACHABLE there should be a match on destination port as 
> well.
> 
> It'd be sent to the source port of the sender and it need not be bound to
> a remote port -- for example, a netfilter rule blocking the destination
> would send an administratively-prohibited ICMP error to a UDP
> application that did not trigger the traffic that caused the error.
> 
> Quite simply, VXLAN uses UDP so it needs to follow the rules of UDP.
> 
> But I don't think there's particular advantage in splitting it up 30,000
> ways when 10 ways would be both practical, for binding, and spread
> traffic to 10 flows potentially.
>

RFC text:
 Outer UDP Header:  This is the outer UDP header with a source
        port provided by the VTEP and the destination port being a well
        known UDP port to be obtained by IANA assignment. It is recommended
        that the source port be a hash of the inner Ethernet frame's headers
        to obtain a level of entropy for ECMP/load balancing of the VM to VM
        traffic across the VXLAN overlay.


You can restrict to a smaller range if that is a requirement of your infrastructure.

Normal UDP applications assign their source port from the ephemeral port range,
so that is what VXLAN does.
