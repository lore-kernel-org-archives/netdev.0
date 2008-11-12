From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 09:12:14 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61252@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110410v5fa8abadib70cebecb282bc1@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B8@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811111008x2e674384kaa560d766a8f643e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C4@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811111059i4d1bc0e6va6032bbfb3f0002c@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611D9@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811120409jc770a1u3b538a413218cf94@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:41572 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbYKLRMS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 12:12:18 -0500
In-Reply-To: <7e0dd21a0811120409jc770a1u3b538a413218cf94@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-12-08 4:10 AM
> To: Lovich, Vitali
> Cc: Evgeniy Polyakov; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> 
> I still believe that we should stop on non-recoverable errors. User
> must be informed that the packet has not been sent.
> If you skip the frame and set status to TP_STATUS_KERNEL. Frame will
> be lost and user will think that malformed frame has been transmitted.
Hence the reason I suggested we keep track of the statistics.  If you think the user will actually care which frame it was that was rejected, then sure set it to TP_STATUS_LOSING.  However, you should still continue with all remaining packets - returning from send won't matter since you'll have filled in the frame.
 
> I'm using TP_STATUS_LOSING in case of non-recoverable error. We can
> maybe introduce a socket option to chose the behavior for
> non-recoverable error.
There's no point in adding socket options to determine the communication protocol with userspace - it's completely redundant.  If someone needs a custom way, they can write their own module or patch this one.
