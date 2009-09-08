From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 8 Sep 2009 09:11:43 -0700
Message-ID: <20090908091143.1e613963@nehalam>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com>
	<20090907171406.6a4b6116@nehalam>
	<1252376254.21261.2052.camel@gandalf.stny.rr.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51670 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbZIHQLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 12:11:47 -0400
In-Reply-To: <1252376254.21261.2052.camel@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Sep 2009 22:17:34 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Mon, 2009-09-07 at 17:14 -0700, Stephen Hemminger wrote:
> > On Mon, 7 Sep 2009 15:58:50 -0700
> > "Luis R. Rodriguez" <mcgrof@gmail.com> wrote:
> > 
> > > A while ago I had read about an effort to consider removing tasklets
> > > [1] or at least trying to not use them. I'm unaware of the progress in
> > > this respect but since reading that article have always tried to
> > > evaluate whether or not we need tasklets on wireless drivers. I have
> > > also wondered whether work in irq context in other parts of the kernel
> > > can be moved to process context, a curious example being timers. I'll
> > > personally be trying to using only process context on bottom halves on
> > > future drivers but I figured it may be a good time to ask how serious
> > > was avoiding tasklets or using wrappers in the future to avoid irq
> > > context is or is it advised. Do we have a general agreement this is a
> > > good step forward to take? Has anyone made tests or changes on a
> > > specific driver from irq context to process context and proven there
> > > are no significant advantages of using irq context where you would
> > > have expected it?
> > > 
> > > Wireless in particular should IMHO not require taskets for anything
> > > time sensitive that I can think about except perhaps changing channels
> > > quickly and to do that appropriately also process pending RX frames
> > > prior to a switch. It remains to be seen experimentally whether or not
> > > using a workqueue for RX processing would affect the time to switch
> > > channels negatively but I doubt it would be significant. I hope to
> > > test that with ath9k_htc.
> > > 
> > > What about gigabit or 10 Gigabit Ethernet drivers ? Do they face any
> > > challenges which would yet need to be proven would not face issues
> > > when processing bottom halves in process context?
> > > 
> > > [1] http://lwn.net/Articles/239633/
> > > 
> > >   Luis
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > Why not use NAPI, which is soft irq? Almost all 1G and 10G drivers
> > use NAPI.
> > 
> > Process context is too slow.
> 
> Well, I'm hoping to prove the opposite. I'm working on some stuff that I
> plan to present at Linux Plumbers. I've been too distracted by other
> things, but hopefully I'll have some good numbers to present by then.
> 


That's great, does it keep the good properties of NAPI (irq disabling
and throttling?)



-- 
