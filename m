From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 14:55:37 -0400 (EDT)
Message-ID: <20150417.145537.237750900198310263.davem@davemloft.net>
References: <20150417162826.GB16743@htj.duckdns.org>
	<20150417.131712.1245246947203158168.davem@davemloft.net>
	<20150417173754.GC16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417173754.GC16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Fri, 17 Apr 2015 13:37:54 -0400

> Hello, David.
> 
> On Fri, Apr 17, 2015 at 01:17:12PM -0400, David Miller wrote:
>> If userland cannot run properly, it is almost certain that neither will
>> your complex reliability layer logic.
> 
> * The bulk of patches are to pipe extended log messages to console
>   drivers and let netconsole relay them to the receiver (and quite a
>   bit of refactoring in the process), which, regardless of the
>   reliability logic, is beneficial as we're currently losing
>   structured logging (dictionary) and other metadata over consoles and
>   regardless of where the reliability logic is implemented, it's a lot
>   easier to have messages IDs.

I do not argue against cleanups and good restructuring of the existing
code.  But you have decided to mix that up with something that is not
exactly non-controversial.

You'd do well to seperate the cleanups from the fundamental changes,
so they can be handled separately.

> * The only thing necessary for reliable transmission are timer and
>   netpoll.  There sure are cases where they go down too but there's a
>   pretty big gap between those two going down and userland getting
>   hosed, but where to put the retransmission and reliability logic
>   definitely is debatable.

I fundamentally disagree, exactly on this point.

If you take an OOPS in a software interrupt handler (basically, all of
the networking receive paths and part of the transmit paths, for
example) you're not going to be taking timer interrupts.

And that's the value of netconsole, the chance (albeit not %100) of
getting messages in those scenerios.
