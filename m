From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 13:09:37 +0100
Message-ID: <7e0dd21a0811120409jc770a1u3b538a413218cf94@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:59340 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbYKLMJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:09:39 -0500
Received: by fg-out-1718.google.com with SMTP id 19so372783fgg.17
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 04:09:37 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611D9@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> So the way I had done it is that non-recoverable errors are those caused by malformed data coming from the user (i.e. packet size is invalid).  In this case, we free the frame and return.  In all other cases, it assumed that the cause was some kind of bad kernel state (i.e. no memory, device busy, etc) that will eventually be recovered from, so we keep retrying or return to the user without changing the status code.

I still believe that we should stop on non-recoverable errors. User
must be informed that the packet has not been sent.
If you skip the frame and set status to TP_STATUS_KERNEL. Frame will
be lost and user will think that malformed frame has been transmitted.

I'm using TP_STATUS_LOSING in case of non-recoverable error. We can
maybe introduce a socket option to chose the behavior for
non-recoverable error.

Best regards,
Johann
-- 
Johann Baudy
johaahn@gmail.com
