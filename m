From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 13:10:34 +0100
Message-ID: <7e0dd21a0811110410v5fa8abadib70cebecb282bc1@mail.gmail.com>
References: <1225450706.5301.94.camel@localhost> <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:55025 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451AbYKKMKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 07:10:36 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2692358fgg.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 04:10:34 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> Found another issue.  I'm not sure how your code managed to work, but in my patch I had to have skb_reset_network_header(skb) after a skb_reserve - otherwise, it would be rejected when I passed it on to the device.

That's not an issue with my device.
It is called in original packet_sendmsg(). I've missed it :)

>
> Also, there's no need to support both header versions in the tx path - since v2 should be used anyways and there's no legacy (v1 headers are deprecated no?), we can use v2 only in the tx path.

I think we have either to use our own TX header (we are using only
status field of V2) or to keep compatibility with all RX/TX headers
available.
Be compatible with V1/V2 makes TX code more flexible if there is a V3
in the future.

> Additionally, if the packet size is too long, the kernel has a responsibility to clear that flag (otherwise that slot will never free up).
I'm not sure to understand, could you please clarify ?

Thanks,
Johann
