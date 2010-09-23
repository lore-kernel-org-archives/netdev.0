From: Christian Riesch <christian@riesch.at>
Subject: Re: [PATCH 6/8] ptp: Added a clock that uses the eTSEC found on the
 MPC85xx.
Date: Thu, 23 Sep 2010 23:26:56 +0200
Message-ID: <4C9BC620.3@riesch.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>	<57b64051c816dc9cb856bbb9f38fc901c9d3d651.1285261535.git.richard.cochran@omicron.at>	<alpine.DEB.2.00.1009231348150.2962@router.home> <20100923214359.3f287b11@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100923214359.3f287b11@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
>> Please do not introduce useless additional layers for clock sync. Load
>> these ptp clocks like the other regular clock modules and make them sync
>> system time like any other clock.
> 
> I don't think you understand PTP. PTP has masters, a system can need to
> be honouring multiple conflicting masters at once.

AFAIK the master's should not be conflicting. The Best Master Clock 
algorithm (BMC) defined in IEEE1588 selects the best master clock. This 
clock distributes its notion of time on the network while the other 
masters, that is the other clocks/nodes that are configured to 
potentially become a master, keep quiet. So usually we will only have 
one source of time (the master clock selected by the BMC) and we will 
steer our single PHC (PTP hardware clock) to follow this master (Of 
course there may be use-cases that require more than one PTP clock, 
e.g., for research purposes).

However, if the clock selected by the BMC is switched off, loses its 
network connection..., the second best clock is selected by the BMC and 
becomes master. This clock may be less accurate and thus our slave clock 
has to switch from one notion of time to another. Is that the conflict 
you mentioned?

Christian
