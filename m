From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Sat, 3 Sep 2005 01:08:13 +0400
Message-ID: <20050902210813.GA18605@yakov.inr.ac.ru>
References: <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu> <43184D79.6040009@mrv.com> <20050902135256.GC12617@yakov.inr.ac.ru> <43185E81.2070300@mrv.com> <20050902154424.GA15060@yakov.inr.ac.ru> <431877EE.6010101@mrv.com> <20050902173228.GA15925@yakov.inr.ac.ru> <4318A06A.1000702@mrv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	John Heffner <jheffner@psc.edu>,
	Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Guillaume Autran <gautran@mrv.com>
Content-Disposition: inline
In-Reply-To: <4318A06A.1000702@mrv.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> The server socket sockopt are all default, except for the 
> TCP_WINDOW_CLAMP which is set to 1400 (application specific).

It is definitely not all. If you do not fiddle with SO_RCVBUF also,
you will always have receiver advertising window of 1400.


11:15:00.922119 IP 10.10.10.3.1150 > 10.10.10.2.3200: S 2246605788:2246605788(0) win 6144 <mss 1460,nop,wscale 0,nop,nop,timestamp 3248699 0>
11:15:00.922791 IP 10.10.10.2.3200 > 10.10.10.3.1150: S 3863556410:3863556410(0) ack 2246605789 win 1400 <mss 1460,nop,nop,timestamp 268188460 3248699,nop,wscale 0>
11:15:00.923118 IP 10.10.10.3.1150 > 10.10.10.2.3200: . ack 1 win 6144 <nop,nop,timestamp 3248699 268188460>
11:15:00.923486 IP 10.10.10.3.1150 > 10.10.10.2.3200: P 1:7(6) ack 1 win 6144 <nop,nop,timestamp 3248699 268188460>
11:15:00.924143 IP 10.10.10.2.3200 > 10.10.10.3.1150: . ack 7 win 1394 <nop,nop,timestamp 268188460 3248699>

cannot happen. SO_RCVBUF is not default.

Alexey
