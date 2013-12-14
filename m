From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 1/2] ipv6: add the IPV6_FL_F_REPLY flag to IPV6_FL_A_GET
Date: Sat, 14 Dec 2013 10:56:50 +0100
Message-ID: <20131214095650.GD23563@order.stressinduktion.org>
References: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr> <52A99262.1090001@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54991 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080Ab3LNJ4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 04:56:51 -0500
Content-Disposition: inline
In-Reply-To: <52A99262.1090001@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 11:39:30AM +0100, Florent Fourcot wrote:
> There two patches extend the flow API. It adds three new actions with
> IPV6_FLOWLABEL_MGR:
> 
>  * setsockopt with IPV6_FL_A_GET and IPV6_FL_F_REPLY set:
>       enable the reply of flow label, packet are sent with the
>       last low label read in packet sent by remote device
>  * setsockopt with IPV6_FL_A_PUT and IPV6_FL_F_REPLY set:
>       disable the flow label reply
>  * getsockopt with IPV6_FL_A_GET and IPV6_FL_F_REPLY set:
>       get the flow label send by the remote device

Sorry, I am not up to date with flowlabel RFCs and applications. Couldn't
such a feature get in the way of RSVP flow control if a remote side
can dictate the label to use for the outgoing connection (I know, your
implementation is opt-in, but I don't want to give application developers
something at hand which could make their software difficult to operate
in future).

> I'm not sure of the best way to do that. First, should we allocate a
> real flow label in the global flow label? I don't think so, and it could
> add hard issues with the system of permission/sharing.

I wouldn't do that either. OTOH we are emitting frames with a flowlabel the
flowmgr does not know about. :/

> Second, I was not sure of the best way for the coverage for all TCP states.

And why would you only support TCP? Wouldn't this work for connected UDP
sockets, too?

Greetings,

  Hannes
