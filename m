From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 8 Sep 2009 10:01:44 -0700
Message-ID: <20090908100144.6e06872b@nehalam>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com>
	<20090907171406.6a4b6116@nehalam>
	<1252376254.21261.2052.camel@gandalf.stny.rr.com>
	<20090908091143.1e613963@nehalam>
	<1252428023.15626.30.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Matt Smith <Matt.Smith@atheros.com>,
	Kevin Hayes <kevin@atheros.com>,
	Bob Copeland <me@bobcopeland.com>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar@winlab.rutgers.edu>, ic.felix@gmail.com
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751864AbZIHRBu@vger.kernel.org>
In-Reply-To: <1252428023.15626.30.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 08 Sep 2009 12:40:23 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Tue, 2009-09-08 at 09:11 -0700, Stephen Hemminger wrote:
> 
> > > > Process context is too slow.
> > > 
> > > Well, I'm hoping to prove the opposite. I'm working on some stuff that I
> > > plan to present at Linux Plumbers. I've been too distracted by other
> > > things, but hopefully I'll have some good numbers to present by then.
> > > 
> > 
> > 
> > That's great, does it keep the good properties of NAPI (irq disabling
> > and throttling?)
> 
> Not exactly sure what you mean by throttling, but I'm assuming it will.
> 
> As for irqs disabling, I'm trying to avoid doing that. Note, the device
> will have its interrupts disabled, but not all other devices will.
> 
> -- Steve
> 
> 

The way NAPI works is that in irq routine, the device disables interrupts
then schedules processing packets, when processing is done irq's are re-enabled.
This means that if machine is being flooded, irq's stay off, and the packets
get discarded (because device hardware ring is full), rather than in software
(because software receive queue is full).


-- 
