From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: "Listenless" TCP over NAT?
Date: Fri, 5 Sep 2008 16:15:12 +0400
Message-ID: <20080905121511.GA14016@2ka.mipt.ru>
References: <WorldClient-F200809051345.AA45130148@butn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>
To: xerces8 <xerces8@butn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:45466 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466AbYIEMPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 08:15:42 -0400
Content-Disposition: inline
In-Reply-To: <WorldClient-F200809051345.AA45130148@butn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2008 at 01:45:13PM +0200, xerces8 (xerces8@butn.net) wrote:
> Recently someone mentioned on this (or maybe other...) list a seldom used
> technique of establishing a TCP connection without one host listening on a port,
> but but acting as "clients" and connecting to the peers port.

This is supported by userspace network stack, which was presented here,
but I'm not sure that exactly unetstack was recommended to you.

http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

> My question: Can this be used to establish a TCP connection between two hosts that
> are both behind a (P)NAT router ?
> 
> (the idea being: NAT router lets outgoing connections thru, and in this case both
> NAT router would  see an "outgoing" connection)

Depending on how NAT is implemented. Usually NAT software will only
allow syn/ack packets before connection is established, and thus if one
peer sends syn packet, and second one sends ack packet (without seeng
ack first) it will work, but if second peer's NAT will send a reset
packet before ack from the peer, first NAT can drop connection (as long
as peer itself).

> If yes, this would simplify the life of many users :-)

It is not directly supported by unetstack, but you can simply extend its
state machine to switch to different state without explicit packet
receiving.

-- 
	Evgeniy Polyakov
