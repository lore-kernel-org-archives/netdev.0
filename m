From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [take29 0/8] kevent: Generic event handling mechanism.
Date: Fri, 29 Dec 2006 14:24:39 +0100
Message-ID: <20061229132439.GA30005@elte.hu>
References: <3154985aa0591036@2ka.mipt.ru> <11668927001365@2ka.mipt.ru> <20061228160137.GA19301@elte.hu> <20061229085503.GB13816@2ka.mipt.ru> <20061229125427.GA23893@elte.hu> <20061229131452.GA5641@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753233AbWL2N2K@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20061229131452.GA5641@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> > (rarer things like mouse/input events can stay with poll 
> > notifications)
> > 
> > and it is /especially/ important to include block IO events in 
> > kevents to be able to judge its performance and scalability relative 
> > to the async IO API and infrastructure.
> 
> Yes, async IO is a significant part, and will be implemented, IMHO, 
> new design I highlighted in linux-fsdevel@ in AIO related thread is 
> the way to go (at least I will imlement it that way).

yes. Note that a prototype exists already: take a look at Tux's "work 
atom" infrastructure of how you can build a relatively straightforward 
state-machine that can be programmed and can be driven even from IRQ 
contexts. Via that i implemented fully asynchronous IO for networking 5 
years ago, and programmed it to handle HTTP and FTP protocol server 
logic, fully asynchronously. (For block IO it also does emulation of 
event handling via the 'cachemiss' kernel threads. State-machine driven 
filesystems are quite hard - but not impossible in the long run.)

It would be a natural thing to extend that fundamental concept to 
user-space as well. /That/ i'd call a generic, grounds-up event handling 
infrastructure. That would be a worthwile unification point for all 
existing IO APIs.

	Ingo
