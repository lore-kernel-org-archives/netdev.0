From: Jeff Garzik <jeff@garzik.org>
Subject: Re: >10% performance degradation since 2.6.18
Date: Sat, 04 Jul 2009 05:19:28 -0400
Message-ID: <4A4F1EA0.3070501@garzik.org>
References: <20090703025607.GK5480@parisc-linux.org> <87skhdaaub.fsf@basil.nowhere.org> <20090703185414.GP23611@kernel.dk> <20090703191321.GO5480@parisc-linux.org> <20090703192235.GV23611@kernel.dk> <20090703194557.GQ5480@parisc-linux.org> <20090703195458.GK2041@one.firstfloor.org> <20090703130421.646fe5cb@infradead.org> <20090703233505.GL2041@one.firstfloor.org> <20090703230408.4433ee39@infradead.org> <20090704084430.GO2041@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org,
	"Styner, Douglas W" <douglas.w.styner@intel.com>,
	Chinang Ma <chinang.ma@intel.com>,
	"Prickett, Terry O" <terry.o.prickett@intel.com>,
	Matthew Wilcox <matthew.r.wilcox@intel.com>,
	Eric.Moore@lsi.com, DL-MPTFusionLinux@lsi.com,
	NetDev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755653AbZGDJWf@vger.kernel.org>
In-Reply-To: <20090704084430.GO2041@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>> for networking, especially for incoming data such as new connections,
>> that isn't the case.. that's more or less randomly (well hash based)
>> distributed.
> 
> Ok. Still binding them all to a single CPU all is quite dumb. It
> makes MSI-X quite useless and probably even harmful.
> 
> We don't default to socket power saving for normal scheduling either, 
> but only when you specify a special knob. I don't see why interrupts
> should be different.

In the pre-MSI-X days, you'd have cachelines bouncing all over the place 
if you distributed networking interrupts across CPUs, particularly given 
that NAPI would run some things on a single CPU anyway.

Today, machines are faster, we have multiple interrupts per device, and 
we have multiple RX/TX queues.  I would be interested to see hard 
numbers (as opposed to guesses) about various new ways to distributed 
interrupts across CPUs.

What's the best setup for power usage?
What's the best setup for performance?
Are they the same?
Is it most optimal to have the interrupt for socket $X occur on the same 
CPU as where the app is running?
If yes, how to best handle when the scheduler moves app to another CPU?
Should we reprogram the NIC hardware flow steering mechanism at that point?

Interesting questions, and I hope we'd see some hard number comparisons 
before solutions start flowing into the kernel.

	Jeff
