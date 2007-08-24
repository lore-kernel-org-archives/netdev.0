From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 21:04:56 +0200
Message-ID: <E1IOeSm-0000bm-Jo@be1.lrz>
References: <8VHRR-45R-17@gated-at.bofh.it> <8VKwj-8ke-27@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linas Vepstas <linas@austin.ibm.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50877 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758335AbXHXTFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 15:05:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas <linas@austin.ibm.com> wrote:
> On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:

>> 3) On modern systems the incoming packets are processed very fast. E=
specially
>> on SMP systems when we use multiple queues we process only a few pac=
kets
>> per napi poll cycle. So NAPI does not work very well here and the in=
terrupt
>> rate is still high.
>=20
> I saw this too, on a system that is "modern" but not terribly fast, a=
nd
> only slightly (2-way) smp. (the spidernet)
>=20
> I experimented wih various solutions, none were terribly exciting.  T=
he
> thing that killed all of them was a crazy test case that someone spru=
ng on
> me:  They had written a worst-case network ping-pong app: send one
> packet, wait for reply, send one packet, etc.
>=20
> If I waited (indefinitely) for a second packet to show up, the test c=
ase
> completely stalled (since no second packet would ever arrive).  And i=
f I
> introduced a timer to wait for a second packet, then I just increased
> the latency in the response to the first packet, and this was noticed=
,
> and folks complained.

Possible solution / possible brainfart:

Introduce a timer, but don't start to use it to combine packets unless =
you
receive n packets within the timeframe. If you receive less than m pack=
ets
within one timeframe, stop using the timer. The system should now have =
a
decent response time when the network is idle, and when the network is
busy, nobody will complain about the latency.-)
--=20
=46unny quotes:
22. When everything's going your way, you're in the wrong lane and and =
going
    the wrong way.
=46ri=DF, Spammer: rsRxhvmk@CaR.7eggert.dyndns.org m@z3T.7eggert.dyndns=
=2Eorg
