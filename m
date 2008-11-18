From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 18 Nov 2008 19:49:00 +0100
Message-ID: <7e0dd21a0811181049i45c4ffd6md964f6acfa0d4c79@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:47898 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbYKRStE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 13:49:04 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2555949fgg.17
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 10:49:00 -0800 (PST)
In-Reply-To: <20081112214601.GA19547@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> If you _do_ want to make it that way, you can remove destructor at all
> and implement own packet-socket-only allocation policy and thus have own
> private destructor without extending skb.

Currently, we are executing sock_alloc_send_skb() to allocate a new
skb from socket.
Then, we replace destructor sock_wfree() with our destructor
packet_skb_destruct() which executes sock_wfree() once status of
packet frame (associated to skb data) has been given back to user
(status changed).

Is this way ok ?
Or shall we implement our own sock_alloc_send_skb()?

Thanks in advance,
Johann


-- 
Johann Baudy
johaahn@gmail.com
