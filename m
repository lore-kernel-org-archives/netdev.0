From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 01 Oct 2013 08:44:17 -0700
Message-ID: <524AEDD1.9010709@hp.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com> <1380203383.3165.172.camel@edumazet-glaptop> <20131001132707.GA7442@cverges-dev-lnx.sentient-energy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Chris Verges <cverges@sentient-energy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:19954 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab3JAPoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:44:21 -0400
In-Reply-To: <20131001132707.GA7442@cverges-dev-lnx.sentient-energy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2013 06:27 AM, Chris Verges wrote:
> The client establishes a connection to the server.  It requests some
> data and gets a response.  The socket remains open.  The server then
> decides, through some asynchronous process, that the radio needs to be
> duty cycled.  So the radio is turned off.
>
> The client attempts to make another request to the device, but
> determines that the connection is dead through the normal retry
> mechanisms.  It's write() operation returns something like EPIPE.  So on
> the client's side, the connection is dead.
>
> But on the server side, the socket is still open and waiting for some
> more data.  The interface and IP address and even the remote client are
> long gone, but the socket still persists and uses system resources.

The protocol between client and server needs to have an 
application-layer "keepalive" mechanism added, and then the server will 
be able to detect a dangling connection without need of any further 
kernel modifications.

If that is not possible, the server can/should set SO_KEEPALIVE and 
perhaps tweak the TCP keepalive settings.  Not as good (IMO) as an 
application-layer keepalive because it only shows that the connection is 
good as far as TCP, but I suppose it could do in a pinch.

rick jones
