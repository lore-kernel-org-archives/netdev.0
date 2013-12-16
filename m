From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH RFC 1/2] ipv6: add the IPV6_FL_F_REPLY flag to IPV6_FL_A_GET
Date: Mon, 16 Dec 2013 19:24:07 +0100
Message-ID: <52AF4547.8020304@enst-bretagne.fr>
References: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr> <52A99262.1090001@enst-bretagne.fr> <20131214095650.GD23563@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:51589 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755017Ab3LPSYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 13:24:09 -0500
In-Reply-To: <20131214095650.GD23563@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> Sorry, I am not up to date with flowlabel RFCs and applications. Couldn't
> such a feature get in the way of RSVP flow control if a remote side
> can dictate the label to use for the outgoing connection (I know, your
> implementation is opt-in, but I don't want to give application developers
> something at hand which could make their software difficult to operate
> in future).
> 

You are right, it could be a problem. But Flow Label are not only
specified for Quality of Service, and RFC's does not forbid this use case.
Since this option is opt-in, it should not be a problem. It is already
possible to set flow label with random values in an application. A
developper can do getsocketopt(FLOWINFO_SEND), and set the flow label to
the result (but it lost first packets of TCP handshakes).

>> I'm not sure of the best way to do that. First, should we allocate a
>> real flow label in the global flow label? I don't think so, and it could
>> add hard issues with the system of permission/sharing.
> 
> I wouldn't do that either. OTOH we are emitting frames with a flowlabel the
> flowmgr does not know about. :/
> 

Hum, what is the best way in your opinion? It is not hard to allocate
the flow label at the first received packet, but there are for me two
issues.
The most important problem is the "sharing" of flow label: what happens
if we receive a packet with a already reserved label? Should we return
an error to the user (and them, how to do that?), or can we ignore it.

The second issue is the renew/release of label, more particularly if the
label sent by the remote device change.


>> Second, I was not sure of the best way for the coverage for all TCP states.
> 
> And why would you only support TCP? Wouldn't this work for connected UDP
> sockets, too?
> 

Actually, I began with TCP, but of course others transport protocols
could support this feature. For the UDP case, it could be implemented in
user space with recvmg/sendmsg (because there are no extra SYN/ACK/etc
packets), but add this option in the kernel space is a good idea.

Thanks for you feedbacks,

Florent.
