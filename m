From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 16:06:20 -0400 (EDT)
Message-ID: <20150417.160620.266679938341020488.davem@davemloft.net>
References: <20150417173754.GC16743@htj.duckdns.org>
	<20150417.145537.237750900198310263.davem@davemloft.net>
	<20150417195238.GH16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417195238.GH16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Fri, 17 Apr 2015 15:52:38 -0400

> Hello,
> 
> On Fri, Apr 17, 2015 at 02:55:37PM -0400, David Miller wrote:
>> > * The bulk of patches are to pipe extended log messages to console
>> >   drivers and let netconsole relay them to the receiver (and quite a
>> >   bit of refactoring in the process), which, regardless of the
>> >   reliability logic, is beneficial as we're currently losing
>> >   structured logging (dictionary) and other metadata over consoles and
>> >   regardless of where the reliability logic is implemented, it's a lot
>> >   easier to have messages IDs.
>> 
>> I do not argue against cleanups and good restructuring of the existing
>> code.  But you have decided to mix that up with something that is not
>> exactly non-controversial.
> 
> Is the controlversial part referring to sending extended messages or
> the reliability part or both?

Anything outside of the non-side-effect cleanups.

> Hmmm... yeah, probably would have been a better idea.  FWIW, the
> patches are stacked roughly in the order of escalating
> controversiness.  Will split the series up.

Thanks.

> Sure, if irq handling is hosed, this won't work but I think there are
> enough other failure modes like oopsing while holding a mutex or
> falling into infinite loop while holding task_list lock (IIRC we had
> something simliar a while ago due to iterator bug).

If you oops while holding a mutex, unless it's the console mutex the
logging process can schedule and likely get the message transmitted.

What we're going to keep discussing is the fact that in return for all
of your unnecessary added complexity, we get something that only applies
in an extremely narrow scope of situations.

That is a very poor value proposition.

It took nearly two decades to get rid of all of the races and locking
problems with current netpoll/netconsole, and it's as simple as can
possibly be.  I do not want to even think about having to worry about
a reliability layer on top of it, that's just too much.
