From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: do_IRQ: stack overflow: 872..
Date: Fri, 07 Jan 2005 19:06:52 +0100
Message-ID: <1105121212.6500.3.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym@pandora.be>, Andi Kleen <ak@suse.de>,
        Crazy AMD K7 <snort2004@mail.ru>, bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050107100017.454ddadc@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-07 at 10:00 -0800, Stephen Hemminger wrote:
> > I don't think it's recursing -- I think the stack trace is just a bit
> > noisy. The problem is that the bridge code, especially with br_netfilter
> > in the equation, is implicated in code paths which are just _too_ deep.
> > This happens when you're bridging packets received in an interrupt while
> > you were deep in journalling code, and it's also been seen with a call
> > trace something like nfs->sunrpc->ip->bridge->br_netfilter.
> 
> Sounds like an argument for interrupt stacks.

The NFS case didn't involve hardware interrupts. Except for the one
which actually detected that the stack had overflowed.

> Probably the solution would be to handle it in the filter code
> that way if we are not filtering, we can use the interrupt path,
> but if filtering just defer to a safer context (like soft irq).

That's also a possibility.

> > Unfortunately that approach would introduce a lot of latency on all
> > packets we pass. Another option would be to have all architectures
> > provide a stack_available() function and for br_dev_xmit() to queue the
> > packet only if we're short of stack, while still sending most packets
> > immediately. 
> 
> NO, that looks like a testablity and portablity nightmare.

Yeah, I suppose I'm inclined to agree.

-- 
dwmw2
