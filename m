From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 19:08:27 +0100
Message-ID: <7e0dd21a0811111008x2e674384kaa560d766a8f643e@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:29177 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbYKKSIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 13:08:30 -0500
Received: by fg-out-1718.google.com with SMTP id 19so91969fgg.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 10:08:28 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B8@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> If the user places a 1 KB packet into the buffer, but then when we try to send it, it turns out the mtu is too small (or something like that), if we don't clear the flag back to TP_STATUS_KERNEL and just return an error, the user will never know.
>
>      --------------------------------------
> 0    | 1 KB frame - status = TP_STATUS_USER |
>      --------------------------------------
> 1    | 1 KB frame - status = TP_STATUS_USER |
>      --------------------------------------
> Etc
>
> So when the user fills up the ring buffer and goes back to frame 0, he won't know that that packet was actually fatally rejected (i.e. the kernel moved on) and will just block waiting for the status to clear (which it never will).  Similarly in the case where the packet gets rejected for being too small.
>
> In other words, when the kernel doesn't send a packet but moves on and doesn't keep trying (as would be the case for the packet size being too small or too big because that is considered an irrecoverable error), it has to notify the user by clearing that status flag for that frame.
>
If there is an error in packet_skb_fill, it returns a negative value
as error code. If a negative value is returned from packet_skb_fill we
exit send() procedure and set status of packet to TP_STATUS_USER.
(this is how error is handled in my last code (not sure committed
one)).
Do you want to introduce a new packet status that marks packet as
ERROR (with TP_STATUS_LOOSING for example?). This way user will be
able to determine easily the one which is failing?

PS: I need to test my last code at office and I'll send it.

Best regards,
Johann

-- 
Johann Baudy
johaahn@gmail.com
