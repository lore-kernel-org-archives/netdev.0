From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 09:05:01 -0600
Message-ID: <4A0AE19D.9040509@nortel.com>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>	<20090508.234815.127227651.davem@davemloft.net>	<4A086DB2.8040703@nortel.com>	<20090511.162436.193717082.davem@davemloft.net>	<4A08C62F.1050105@nortel.com>
	<20090512081237.GA16403@elte.hu>	<4A09933B.8010606@nortel.com>
	<874ovpmmdq.fsf@basil.nowhere.org>	<4A0AC9EC.6070908@nortel.com>	<20090513141532.GT19296@one.firstfloor.org>	<alpine.LFD.2.00.0905131612180.3561@localhost.localdomain>
	<87my9hkrmw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Steven Rostedt <rostedt@goodmis.org>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <87my9hkrmw.fsf@basil.nowhere.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Thomas Gleixner <tglx@linutronix.de> writes:

>>Err, no. Chris is completely correct:
>>
>>        if (!in_interrupt())
>>		wakeup_softirqd();
> 
> Yes you have to wake it up just in case, but it doesn't normally
> process the data because a normal softirq comes in faster. It's
> just a safety policy. 

What about the scenario I raised earlier, where we have incoming network
packets, no hardware interrupts coming in other than the timer tick, and
a high-priority userspace app is spinning on recvmsg() with MSG_DONTWAIT
set?

As far as I can tell, in this scenario softirqs may not get processed on
return from a syscall (contradicting the documentation).  In the worst
case, they may not get processed until the next timer tick.

Chris
