From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 18 Nov 2008 11:46:18 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA6152F@NASANEXMB10.na.qualcomm.com>
References: <20081111192954.GA19409@ioremap.net>
	 <20081112135828.GA30946@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
	 <20081112174114.GA4743@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
	 <20081112181134.GA5396@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com>
	 <20081112191400.GA6291@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6128D@NASANEXMB10.na.qualcomm.com>
	 <20081112214601.GA19547@ioremap.net>
 <7e0dd21a0811181049i45c4ffd6md964f6acfa0d4c79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:13993 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbYKRTqV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 14:46:21 -0500
In-Reply-To: <7e0dd21a0811181049i45c4ffd6md964f6acfa0d4c79@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-18-08 10:49 AM
> To: Evgeniy Polyakov
> Cc: Lovich, Vitali; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Evgeniy,
> 
> > If you _do_ want to make it that way, you can remove destructor at
> all
> > and implement own packet-socket-only allocation policy and thus have
> own
> > private destructor without extending skb.
> 
> Currently, we are executing sock_alloc_send_skb() to allocate a new
> skb from socket.
> Then, we replace destructor sock_wfree() with our destructor
> packet_skb_destruct() which executes sock_wfree() once status of
> packet frame (associated to skb data) has been given back to user
> (status changed).
Just a clarification - sock_wfree is called !before! we set the status back.  Not extremely important, but it's cleaner that way & the constant sock_wfree/sock_alloc_send_skb is more likely to keep reallocating the same memory.

Oh, and Johann, here are the perf #s we were talking about off the list.

Frame size/Packets per second/Line-rate (GBit/s)
8942/144270/9.61
1500/387544/4.32
 500/591648/2.19
  43/925328/0.30  (43 bytes is about 1-byte of payload for a UDP packet)

I should have the latency #'s numbers in a little while.

Vitali
