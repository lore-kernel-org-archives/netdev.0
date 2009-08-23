From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Sun, 23 Aug 2009 21:55:45 +0400
Message-ID: <a4423d670908231055o2bb65fe0le2c33fe94b660b38@mail.gmail.com>
References: <200907240257.10906.marek.vasut@gmail.com>
	 <a4423d670907290416h4a0796c2s665d3f8ca0755e67@mail.gmail.com>
	 <200908051602.34501.marek.vasut@gmail.com>
	 <200908220054.31438.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Miao <eric.y.miao@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	samuel@sortiz.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Marek Vasut <marek.vasut@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:5572 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932457AbZHWRzo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 13:55:44 -0400
Received: by ey-out-2122.google.com with SMTP id 22so479647eye.37
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2009 10:55:45 -0700 (PDT)
In-Reply-To: <200908220054.31438.marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/8/22 Marek Vasut <marek.vasut@gmail.com>:
> Dne St 5. srpna 2009 16:02:34 Marek Vasut napsal(a):
>> Dne St 29. =C4=8Dervence 2009 13:16:25 Alexander Beregalov napsal(a)=
:
>> > 2009/7/28 Eric Miao <eric.y.miao@gmail.com>:
>> > > Marek Vasut wrote:
>> > >> Hi!
>> > >>
>> > >> This patch fixes broken pxaficp-ir. The problem was in incorrec=
t
>> > >> net_device_ops being specified which prevented the driver from
>> > >> operating. The symptoms were:
>> > >> =C2=A0- failing ifconfig for IrLAN, resulting in
>> > >> =C2=A0 =C2=A0 =C2=A0 SIOCSIFFLAGS: Cannot assign requested addr=
ess
>> > >> =C2=A0- irattach working for IrCOMM, but the port stayed disabl=
ed
>> > >>
>> > >> Moreover this patch corrects missing sysfs device link.
>> > >>
>> > >> btw. guys, be honest, when did you last tested pxaficp-ir on re=
al
>> > >> hardware? ;-)
>> > >
>> > > Well, this seems to be brought by the net_device_ops change, whi=
ch
>> > > seems to happen silently without any of us being notified.
>> > >
>> > > OK, netdev and Alex are copied, so that we can look into this is=
sue a
>> > > bit deeper:
>> > >
>> > > 1. it looks to me that SIOCSIFFLAGS actually returned -EADDRNOTA=
VAIL,
>> > > which is likely caused by eth_validate_addr, the default eth_add=
r comes
>> > > with irda should be "00:00:00:00:00:00" if not explicitly specif=
ied
>> > > (kzalloc), and this should be the problem, solution ? =C2=A0Eith=
er give a
>> > > valid address to the irda net_device or remove this
>> > > 'ndo_validate_addr'. And which is a correct fix will impact on t=
he
>> > > .ndo_set_mac_address
>> > >
>> > > 2. '.ndo_change_mtu' ? It looks to me that Irda device doesn't c=
are too
>> > > much about the MTU, eth_change_mtu is supposed to work just fine=
 and
>> > > not to cause any side effects, and may just benefit later irda d=
evice
>> > > drivers if there is a weird device happens to care about MTU
>> > >
>> > > - eric
>> > >
>> > > Marek's original patch in attachment.
>> >
>> > Sorry about that and thanks.
>> > Then we should fix the rest of irda drivers in the same way.
>>
>> Hi!
>> Was my patch applied or what's the current status? Thanks
>
> Hi!
> any updates ? Are we letting this into .32 in current broken state?
>

David, please have a look. Will you apply it?
