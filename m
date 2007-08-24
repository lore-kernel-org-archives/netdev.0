From: akepner@sgi.com
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 08:37:03 -0700
Message-ID: <20070824153703.GN5592@sgi.com>
References: <200708241559.17055.ossthema@de.ibm.com>
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
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:43712 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758721AbXHXPiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 11:38:09 -0400
Content-Disposition: inline
In-Reply-To: <200708241559.17055.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:
> .......
> 3) On modern systems the incoming packets are processed very fast. Es=
pecially
> =A0 =A0on SMP systems when we use multiple queues we process only a f=
ew packets
> =A0 =A0per napi poll cycle. So NAPI does not work very well here and =
the interrupt=20
> =A0 =A0rate is still high. What we need would be some sort of timer p=
olling mode=20
> =A0 =A0which will schedule a device after a certain amount of time fo=
r high load=20
> =A0 =A0situations. With high precision timers this could work well. C=
urrent
> =A0 =A0usual timers are too slow. A finer granularity would be needed=
 to keep the
>    latency down (and queue length moderate).
>=20

We found the same on ia64-sn systems with tg3 a couple of years=20
ago. Using simple interrupt coalescing ("don't interrupt until=20
you've received N packets or M usecs have elapsed") worked=20
reasonably well in practice. If your h/w supports that (and I'd=20
guess it does, since it's such a simple thing), you might try=20
it.

--=20
Arthur

