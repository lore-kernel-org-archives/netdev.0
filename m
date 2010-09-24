From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 6/8] ptp: Added a clock that uses the eTSEC found on the
	MPC85xx.
Date: Fri, 24 Sep 2010 12:52:38 +0100
Message-ID: <20100924125238.4c30f3a4@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<57b64051c816dc9cb856bbb9f38fc901c9d3d651.1285261535.git.richard.cochran@omicron.at>
	<alpine.DEB.2.00.1009231348150.2962@router.home>
	<20100923214359.3f287b11@lxorguk.ukuu.org.uk>
	<4C9BC620.3@riesch.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	Richard Cochran <richardcochran@gmail.com>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Christian Riesch <christian@riesch.at>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4C9BC620.3@riesch.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> However, if the clock selected by the BMC is switched off, loses its 
> network connection..., the second best clock is selected by the BMC and 
> becomes master. This clock may be less accurate and thus our slave clock 
> has to switch from one notion of time to another. Is that the conflict 
> you mentioned?

No you get situations where you have policy reasons for trusting
particular clocks for particular things.

So you may have a PTP or NTP clock providing basic system time but also
have other PTP clocks that are actually being used for synchronization
work.

With NTP it's not so far been a big issue - NTP isn't used for industrial
high precision control and the cases we end up with multiple NTP clocks
it's on a virtualised systems where it is isolated.

With high precision clocks you sometimes want to honour a specific PTP
time source and use it rather than try and merge it with your other time
sources (which may differ from the equipment elsewhere). What matters is
things like all the parts of a several mile long conveyor belt of hot
steel slab stopping at the same moment [1].

In lots of control applications you've got assorted different time planes
which wish to talk their own time and you have to accept it, so we need
to support that kind of use.

I agree entirely the normal boring 'I installed my distro and..' case for
PTP or for NTP is merging all the sources, running the algorithm and using
the system time for it. Likewise almost all "normal" application code
will be watching system time.

Alan
[1] Which was my first encounter with writing Vax/VMS assembly language
