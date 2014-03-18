From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 03/12] can: c_can: Make it SMP safe
Date: Tue, 18 Mar 2014 20:40:10 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403182037580.18573@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de> <20140318171126.844179673@linutronix.de> <5328947F.7070902@pengutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5328947F.7070902@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Mar 2014, Marc Kleine-Budde wrote:

> On 03/18/2014 06:19 PM, Thomas Gleixner wrote:
> > The hardware has two message control interfaces, but the code only
> > uses the first one. So on SMP the following can be observed:
> > 
> > CPU0 	       	CPU1
> > rx_poll()
> >   write IF1	xmit()
> > 		write IF1
> >   write IF1			
> > 
> > That results in corrupted message object configurations. The TX/RX is
> > not globally serialized it's only serialized on a core.
> > 
> > Simple solution: Let RX use IF1 and TX use IF2 and all is good.
> 
> Do both c_can and d_can have two control interfaces?

According to the manual it has.

Thanks,

	tglx
