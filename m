From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] tcp : how many times a frame can possibly be
 retransmitted ?
Date: Wed, 24 Aug 2011 21:45:32 +0200
Message-ID: <1314215132.2506.7.camel@edumazet-laptop>
References: <1314202918.2296.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <3482698A-C35B-4BED-AEEF-EBA135991705@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>,
	Hannemann Arnd <arnd@arndnet.de>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64417 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab1HXTph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 15:45:37 -0400
Received: by wyg24 with SMTP id 24so1115509wyg.19
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 12:45:36 -0700 (PDT)
In-Reply-To: <3482698A-C35B-4BED-AEEF-EBA135991705@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 ao=C3=BBt 2011 =C3=A0 21:03 +0200, Alexander Zimmermann =
a =C3=A9crit :
> Hi Eric,
>=20
> Am 24.08.2011 um 18:21 schrieb Eric Dumazet:
>=20
> > On one dev machine running net-next, I just found strange tcp sessi=
ons
> > that retransmit a frame forever (The other peer disappeared)
>=20
> not forever...
> If remember correctly you will stop after 120s.
>=20

Hi Alexander

I just tried again one session, and got much more delay than that.

It stops because of a side effect, "icsk_retransmits" being a 8bit
field.

Every 256 retransmits, it becomes 255+1 -> 0

retransmits_timed_out() immediately returns false.

And backoff increases at this time.

Eventually, we retransmit 256*15 times, process 256*15 ICMP messages.

Thanks
