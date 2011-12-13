From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Tue, 13 Dec 2011 04:52:29 +0100
Message-ID: <1323748349.2583.38.camel@edumazet-laptop>
References: <cover.1323744724.git.richardcochran@gmail.com>
	 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
	 <1323746932.2583.33.camel@edumazet-laptop>
	 <20111213034132.GC9604@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57784 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab1LMDwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 22:52:34 -0500
Received: by wgbdr13 with SMTP id dr13so12781462wgb.1
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 19:52:32 -0800 (PST)
In-Reply-To: <20111213034132.GC9604@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 d=C3=A9cembre 2011 =C3=A0 04:41 +0100, Richard Cochran a =C3=
=A9crit :
> On Tue, Dec 13, 2011 at 04:28:52AM +0100, Eric Dumazet wrote:
> >=20
> > Adding a (shared) spinlock on a multiqueue device is source of extr=
a
> > delay (because of extra cache line trafic), I guess.
> >=20
> > It seems current code doesnt need a spinlock, maybe it was a bug ?
>=20
> (I didn't think about the old code. I only deleted it. ;)
>=20
> The spinlock is needed because reading the 64 bit time value involves
> reading two 32 registers. The first read latches the value. Ditto for
> writing.
>=20
> In addition, here we have to watch the most significant bit for
> one-to-zero transistion, in order to keep count of the overflow.
>=20
> It is too bad that we have to take the spinlock for every time stampe=
d
> packet, but it is the hardware's fault for not providing a 64 bit wid=
e
> nanosecond time register.
>=20

Yes, probably. Are you sure a workaround is not possible, using a
seqlock for synchronization of threads, and two hardware reads ?

Or maybe it doesnt matter at all :)
