From: Piotrek D <regis44@gmail.com>
Subject: Re: changing the qdisc class speed rate
Date: Sat, 30 May 2009 10:19:36 +0200
Message-ID: <620d582f0905300119y5e4b6962s40e0e276074720b6@mail.gmail.com>
References: <50214222-779D-4C49-9151-C725C8F470D5@gmail.com>
	 <20090527222158.42f71e28@nehalam>
	 <620d582f0905291203n69bce7bkd2c06d48d27f5003@mail.gmail.com>
	 <4A2046D1.3050402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:41630 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbZE3ITg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 04:19:36 -0400
Received: by fxm12 with SMTP id 12so4806309fxm.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 01:19:36 -0700 (PDT)
In-Reply-To: <4A2046D1.3050402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, this was exactly what I was looking for :)
After multiplying  all of the values in the rtab->data array I have
been able to change the traffic rate for that queue.

Piotrek D.


> /* Length to Time (L2T) lookup in a qdisc_rate_table, to determine ho=
w
> =A0 long it will take to send a packet given its size.
> =A0*/
> static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned i=
nt pktlen)
> {
> =A0 =A0 =A0 =A0int slot =3D pktlen + rtab->rate.cell_align + rtab->ra=
te.overhead;
> =A0 =A0 =A0 =A0if (slot < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D 0;
> =A0 =A0 =A0 =A0slot >>=3D rtab->rate.cell_log;
> =A0 =A0 =A0 =A0if (slot > 255)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return (rtab->data[255]*(slot >> 8) + =
rtab->data[slot & 0xFF]);
> =A0 =A0 =A0 =A0return rtab->data[slot];
> }
>
> This function controls rates and these rtab values matter here.
>
> Jarek P.
>

>> --
