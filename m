From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 12:14:49 -0700
Message-ID: <20100823121449.29419771@nehalam>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41688 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223Ab0HWTOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 15:14:52 -0400
In-Reply-To: <1282590037-18566-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Aug 2010 21:00:37 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> The TCP quick ACK mechanism analyze if a connection is interactive or
> not. Per default the quick ACK mechanism is enabled and ACK packets are
> triggered instantly to raise the CWND fast - which is clever for
> bulk data (non-interactive) flows. On the other hand interactive protocols
> like HTTP, SMTP or XMPP will suffer from the quick ACK mechanism
> because one additional packets is generated. A simple heuristic
> detects if a connection is interactive (pingpong) and if so,
> disable the quick ACK. But, the mechanism is not in the ability to
> blindly guess if a connection is interactive, and so it must wait for at
> least one return packet with payload.
> 
> For the server side this requires one additional packet because (packet
> number 5 and 6 can be combined):
> 
> 192.168.1.35.44833 > 78.47.222.210.80: Flags [S], seq 2854340018, win 5840, options [mss 1460,sackOK,TS val 4382726 ecr 0,nop,wscale 7], length 0
> 78.47.222.210.80 > 192.168.1.35.44833: Flags [S.], seq 719041385, ack 2854340019, win 5792, options [mss 1452,sackOK,TS val 2606891996 ecr 4382726,nop,wscale 7], length 0
> 192.168.1.35.44833 > 78.47.222.210.80: Flags [.], ack 1, win 46, options [nop,nop,TS val 4382730 ecr 2606891996], length 0
> 192.168.1.35.44833 > 78.47.222.210.80: Flags [P.], seq 1:682, ack 1, win 46, options [nop,nop,TS val 4382730 ecr 2606891996], length 681
> 78.47.222.210.80 > 192.168.1.35.44833: Flags [.], ack 682, win 56, options [nop,nop,TS val 2606892002 ecr 4382730], length 0
> 78.47.222.210.80 > 192.168.1.35.44833: Flags [.], seq 1:1441, ack 682, win 56, options [nop,nop,TS val 2606892002 ecr 4382730], length 1440
> 192.168.1.35.44833 > 78.47.222.210.80: Flags [.], ack 1441, win 69, options [nop,nop,TS val 4382737 ecr 2606892002], length 0
> 
> This patch provides a sysctl interface for the administrator to globally
> enable or disable TCP quick ACKs. Short lived protocols like HTTP will
> save a non unimportant portion of packets!

If this is configurable (still not sure about having yet more
TCP knobs). It should either be per-socket or a route metric so it can
be controlled on a per-path basis.


-- 
