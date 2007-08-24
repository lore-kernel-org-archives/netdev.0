From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 17:47:15 +0200
Message-ID: <200708241747.16592.ossthema@de.ibm.com>
References: <200708241559.17055.ossthema@de.ibm.com> <20070824153703.GN5592@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: akepner@sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760363AbXHXPsL@vger.kernel.org>
In-Reply-To: <20070824153703.GN5592@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Friday 24 August 2007 17:37, akepner@sgi.com wrote:
> On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:
> > .......
> > 3) On modern systems the incoming packets are processed very fast. =
Especially
> > =A0 =A0on SMP systems when we use multiple queues we process only a=
 few packets
> > =A0 =A0per napi poll cycle. So NAPI does not work very well here an=
d the interrupt=20
> > =A0 =A0rate is still high. What we need would be some sort of timer=
 polling mode=20
> > =A0 =A0which will schedule a device after a certain amount of time =
for high load=20
> > =A0 =A0situations. With high precision timers this could work well.=
 Current
> > =A0 =A0usual timers are too slow. A finer granularity would be need=
ed to keep the
> >    latency down (and queue length moderate).
> >=20
>=20
> We found the same on ia64-sn systems with tg3 a couple of years=20
> ago. Using simple interrupt coalescing ("don't interrupt until=20
> you've received N packets or M usecs have elapsed") worked=20
> reasonably well in practice. If your h/w supports that (and I'd=20
> guess it does, since it's such a simple thing), you might try=20
> it.
>=20

I don't see how this should work. Our latest machines are fast enough t=
hat they
simply empty the queue during the first poll iteration (in most cases).
Even if you wait until X packets have been received, it does not help f=
or
the next poll cycle. The average number of packets we process per poll =
queue
is low. So a timer would be preferable that periodically polls the=20
queue, without the need of generating a HW interrupt. This would allow =
us
to wait until a reasonable amount of packets have been received in the =
meantime
to keep the poll overhead low. This would also be useful in combination
with LRO.

Regards,
Jan-Bernd
