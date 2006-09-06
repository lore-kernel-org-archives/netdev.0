From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] FRV: do_gettimeofday() should no longer use tickadj
Date: Thu, 07 Sep 2006 09:01:32 +1000
Message-ID: <1157583693.22705.254.camel@localhost.localdomain>
References: <20060906125626.GA3718@elte.hu>  <20060906094301.GA8694@elte.hu>
	 <1157507203.2222.11.camel@localhost> <20060905132530.GD9173@stusta.de>
	 <20060901015818.42767813.akpm@osdl.org>
	 <6260.1157470557@warthog.cambridge.redhat.com>
	 <8430.1157534853@warthog.cambridge.redhat.com>
	 <13982.1157545856@warthog.cambridge.redhat.com>
	 <17274.1157553962@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, john stultz <johnstul@us.ibm.com>,
	Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965269AbWIFXFp@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
In-Reply-To: <17274.1157553962@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Under some circumstances I can work out which sources have triggered which
> interrupts (there are various off-CPU FPGAs which implement auxiliary PICs that
> do announce their sources), but the aux-PIC channels are grouped together upon
> delivery to the CPU PIC, so some of the ACK'ing has to be done at the group
> level.
> 
> > how is this not possible via genirq?
> 
> How is it possible with genirq?

Well, genirq gives you more flexibility than the current mecanism so ...

If I understand correctly, you need to do scray stuff to figure out your
toplevel irq, which shound't be a problem with either mecanisms... 

Now, if you have funky cascades, then you can always group them into a
virtual irq cascade line and have a special chained flow handler that
does all the "figuring out" off those... it's up to you. 

In general, I found genirq allowed me to do more fancy stuff, and end up
with actually less hooks and indirect function calls on the path to a
given irq than before as you can use tailored flow handlers that do just
the right thing.

Ben.
