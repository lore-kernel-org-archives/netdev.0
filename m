From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 10:19:43 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C4@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110410v5fa8abadib70cebecb282bc1@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B8@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811111008x2e674384kaa560d766a8f643e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:29967 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbYKKSTq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 13:19:46 -0500
In-Reply-To: <7e0dd21a0811111008x2e674384kaa560d766a8f643e@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-11-08 10:08 AM
> To: Lovich, Vitali
> Cc: Evgeniy Polyakov; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> If there is an error in packet_skb_fill, it returns a negative value
> as error code. If a negative value is returned from packet_skb_fill we
> exit send() procedure and set status of packet to TP_STATUS_USER.
> (this is how error is handled in my last code (not sure committed
> one)).
> Do you want to introduce a new packet status that marks packet as
> ERROR (with TP_STATUS_LOOSING for example?). This way user will be
> able to determine easily the one which is failing?
> 
> PS: I need to test my last code at office and I'll send it.
I'm saying that that frame's status should just be set to TP_STATUS_KERNEL, not user.  The kernel wants nothing to do with this frame any more and the user needs to know that.  I was going to add statistics tracking to keep track of how many packets were sent vs rejected.  This was more of an issue with my approach where I had a dedicated kernel thread doing all of this.

Thanks,
Vitali
