From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Tue, 2 Sep 2008 23:46:04 +0400
Message-ID: <20080902194603.GA2825@2ka.mipt.ru>
References: <7e0dd21a0809021127n35cd38d7m98be5ee5d7158788@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Ulisses Alonso =?utf-8?Q?Camar=C3=B3?= <uaca@alumni.uv.es>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:49341 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168AbYIBTtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 15:49:40 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809021127n35cd38d7m98be5ee5d7158788@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Tue, Sep 02, 2008 at 08:27:36PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> I've made lot of tests, playing with jumbo frames, raw sockets, ...
> I've never exceeded ~25Mbytes/s. So I've decided to analyze deeply the
> packet socket transmission process.
> 
> The main blocking point was the memcpy_fromiovec() function that is
> located in the packet_sendmsg() of af_packet.c.

Can you saturate the link with usual tcp/udp socket?

> But, I would like to get as much criticism as possible in order to
> start a discussion with experts about a conceivable way to mix
> zero-copy, sk_buff management and packet socket.
> Which is perhaps impossible with current network kernel flow ...

Did you try vmsplice and splice?
It is the preferred way to do a zero-copy.

-- 
	Evgeniy Polyakov
