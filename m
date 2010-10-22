From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path (Was Re: [Bugme-new]
 [Bug 19692] New: linux-2.6.36-rc5 crash with gianfar ethernet at full line
 rate traffic)
Date: Fri, 22 Oct 2010 08:14:08 +0200
Message-ID: <1287728048.9059.124.camel@edumazet-laptop>
References: <20101010103236.GA1919@del.dom.local>
	 <20101015085853.GA8091@ff.dom.local>
	 <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com>
	 <20101016194815.GA1894@del.dom.local>
	 <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com>
	 <20101019100636.GA9246@ff.dom.local>
	 <AANLkTimakJjwL9v2Ztpce3Xnjb_r5XB=rGoJc9pZKE12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: emin ak <eminak71@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62766 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab0JVGOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 02:14:20 -0400
Received: by wwe15 with SMTP id 15so436984wwe.1
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 23:14:19 -0700 (PDT)
In-Reply-To: <AANLkTimakJjwL9v2Ztpce3Xnjb_r5XB=rGoJc9pZKE12@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 22 octobre 2010 =C3=A0 08:42 +0300, emin ak a =C3=A9crit :
> Hi Jarek;
>=20
> > Maybe for now let's try to get and see this type 1 again? Since the
> > recycle path is suspicious a bit to me, probably limiting memory or
> > slowing tx (maybe different mtus on eth0 and 1) under heavy multi c=
pu
> > load might help.
> >
>=20
> I'll do my best with your recommended test conditions. I have reserve=
d
> a machine and two ports of  hw packet generator, now we'll see if thi=
s
> error will occur again or not. (But I'am not sure if I want to see it
> again:)

Really this rx recycle affair is more than suspicious to me too.

Is it really worth the pain ?

Are MTU changes handled correctly ? ( must flush rx_recycle queue...)

Using a single rx_recycle queue in a supposed multiqueue driver makes
absolutely _no_ sense to me. This adds an artificial contention point.



