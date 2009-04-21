From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 22:13:35 +0200
Message-ID: <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <alpine.DEB.1.10.0904211131340.21796@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:50120 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbZDUUNi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 16:13:38 -0400
Received: by fxm2 with SMTP id 2so2726777fxm.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 13:13:36 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.10.0904211131340.21796@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,

> Could you clean then states up a bit to reflect what they actually me=
an?
>
> TP_STATUS_AVAILABLE =A0 =A0 =A0 =A0 =A0 =A0 =3D> Frame is available
> TP_STATUS_SEND_REQUEST =A0 =A0 =A0 =A0 =A0=3D> Frame waits for sendin=
g
> TP_STATUS_SENDING =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D> Frame is being sen=
t.

Ok

> Also can you ensure that send() continues to send if I concurrently s=
et
> the status to TP_STATUS_SEND_REQUEST from another thread? How it is
> serialized anyways? Status is an atomic value? Or do you rely on stat=
us
> only being modified while send() is running?

TP_STATUS_KERNEL =3D> TP_STATUS_SEND_REQUEST: only performed by user.
TP_STATUS_SEND_REQUEST =3D> TP_STATUS_SENDING  only performed by kernel
TP_STATUS_SENDING =3D> TP_STATUS_KERNEL  only performed by kernel.

Only one thread is allowed to change status values from user space.
This way, you can take advantage of smp. One thread is filling the
buffer changing status  from TP_STATUS_KERNEL to
TP_STATUS_SEND_REQUEST , another is calling send() in loop
(MSG_DONTBLOCK option can be used).

You can also perform filling and send() sequentially

An example can be found at:
http://wiki.gnu-log.net/index.php5?title=3DLinux_packet_mmap
It can customize almost all parameters, use multi_thread, use DGRAM ...

Thanks,
Johann
