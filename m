From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 15:52:38 -0400
Message-ID: <20150417195238.GH16743@htj.duckdns.org>
References: <20150417162826.GB16743@htj.duckdns.org>
 <20150417.131712.1245246947203158168.davem@davemloft.net>
 <20150417173754.GC16743@htj.duckdns.org>
 <20150417.145537.237750900198310263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150417.145537.237750900198310263.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Apr 17, 2015 at 02:55:37PM -0400, David Miller wrote:
> > * The bulk of patches are to pipe extended log messages to console
> >   drivers and let netconsole relay them to the receiver (and quite a
> >   bit of refactoring in the process), which, regardless of the
> >   reliability logic, is beneficial as we're currently losing
> >   structured logging (dictionary) and other metadata over consoles and
> >   regardless of where the reliability logic is implemented, it's a lot
> >   easier to have messages IDs.
> 
> I do not argue against cleanups and good restructuring of the existing
> code.  But you have decided to mix that up with something that is not
> exactly non-controversial.

Is the controlversial part referring to sending extended messages or
the reliability part or both?

> You'd do well to seperate the cleanups from the fundamental changes,
> so they can be handled separately.

Hmmm... yeah, probably would have been a better idea.  FWIW, the
patches are stacked roughly in the order of escalating
controversiness.  Will split the series up.

> > * The only thing necessary for reliable transmission are timer and
> >   netpoll.  There sure are cases where they go down too but there's a
> >   pretty big gap between those two going down and userland getting
> >   hosed, but where to put the retransmission and reliability logic
> >   definitely is debatable.
> 
> I fundamentally disagree, exactly on this point.
> 
> If you take an OOPS in a software interrupt handler (basically, all of
> the networking receive paths and part of the transmit paths, for
> example) you're not going to be taking timer interrupts.

Sure, if irq handling is hosed, this won't work but I think there are
enough other failure modes like oopsing while holding a mutex or
falling into infinite loop while holding task_list lock (IIRC we had
something simliar a while ago due to iterator bug).  Whether being
more robust in those cases is worthwhile is definitely debatable.  I
thought the added complexity was small enough but the judgement can
easily fall on the other side.

> And that's the value of netconsole, the chance (albeit not %100) of
> getting messages in those scenerios.

None of the changes harm that in any way.  Anyways, I'll split up the
extended message and the rest.

Thanks.

-- 
tejun
