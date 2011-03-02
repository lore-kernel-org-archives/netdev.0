From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Wed, 02 Mar 2011 17:50:44 +0100
Message-ID: <1299084644.2920.24.camel@edumazet-laptop>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	 <1298793252.8726.45.camel@edumazet-laptop>
	 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	 <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
	 <cbb9e1113901f1a324359b6ed3f1a611@localhost>
	 <AANLkTikje6rvjSfEA3CvUjdgFwzk-SBZDdO5kQvi6LZy@mail.gmail.com>
	 <AANLkTin_jY_J7tJseMLVmrQVVRezOVQTGCgB_6tefgXJ@mail.gmail.com>
	 <alpine.DEB.1.10.1103010137400.7942@uplift.swm.pp.se>
	 <20110301222531.24832a93@nehalam>
	 <alpine.DEB.1.10.1103020736260.7942@uplift.swm.pp.se>
	 <20110301230754.5ef4ab35@nehalam>
	 <alpine.DEB.1.10.1103021739550.7942@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	John Heffner <johnwheffner@gmail.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Albert Cahalan <acahalan@gmail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1103021739550.7942@uplift.swm.pp.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 02 mars 2011 =C3=A0 17:41 +0100, Mikael Abrahamsson a =C3=A9=
crit :
> On Tue, 1 Mar 2011, Stephen Hemminger wrote:
>=20
> > Also WRED is not default on faster links because it can't be done f=
ast=20
> > enough.
>=20
> Before this propagates as some kind of truth. Cisco modern core route=
rs=20
> have no problems doing WRED at wirespeed, the above statement is not =
true.
>=20

looking at cisco docs you provided
( <http://www.cisco.com/en/US/docs/ios/12_0s/feature/guide/12stbwr.html=
>
 )
, it seems the WRED time limits (instead of bytes/packets limits) are
internaly converted to bytes/packets limits


quote :=20

When the queue limit threshold is specified in milliseconds, the number
of milliseconds is internally converted to bytes using the bandwidth
available for the class.=20


So it seems its only a facility provided, and queues are still managed
with bytes/packets limits...

WRED is able to prob drop a packet when this packet is enqueued. At tim=
e
of enqueue, we dont know yet the time of dequeue, unless bandwidth is
known.
