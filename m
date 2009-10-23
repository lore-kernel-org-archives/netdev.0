From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Irq architecture for multi-core network driver.
Date: Fri, 23 Oct 2009 16:22:36 -0700
Message-ID: <m17huln1ab.fsf@fess.ebiederm.org>
References: <4AE0D14B.1070307@caviumnetworks.com>
	<4AE0D72A.4090607@nortel.com> <4AE0DB98.1000101@caviumnetworks.com>
	<m13a5apmm0.fsf@fess.ebiederm.org>
	<4807377b0910231028g60b479cfycdbf3f4e25384c58@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@caviumnetworks.com>,
	Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips <linux-mips@linux-mips.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752182AbZJWXWi@vger.kernel.org>
In-Reply-To: <4807377b0910231028g60b479cfycdbf3f4e25384c58@mail.gmail.com> (Jesse Brandeburg's message of "Fri\, 23 Oct 2009 10\:28\:10 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg <jesse.brandeburg@gmail.com> writes:

> On Fri, Oct 23, 2009 at 12:59 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> David Daney <ddaney@caviumnetworks.com> writes:
>>> Certainly this is one mode of operation that should be supported, but I would
>>> also like to be able to go for raw throughput and have as many cores as possible
>>> reading from a single queue (like I currently have).
>>
>> I believe will detect false packet drops and ask for unnecessary
>> retransmits if you have multiple cores processing a single queue,
>> because you are processing the packets out of order.
>
> So, the way the default linux kernel configures today's many core
> server systems is to leave the affinity mask by default at 0xffffffff,
> and most current Intel hardware based on 5000 (older core cpus), or
> 5500 chipset (used with Core i7 processors) that I have seen will
> allow for round robin interrupts by default.  This kind of sucks for
> the above unless you run irqbalance or set smp_affinity by hand.

On x86 if you have > 8 cores the hardware does not support any form of
irq balancing.  You do have an interesting point.

How often and how much does irq balancing hurt us.

> Yes, I know Arjan and others will say you should always run
> irqbalance, but some people don't and some distros don't ship it
> enabled by default (or their version doesn't work for one reason or
> another)  

irqbalance is actually more likely to move irqs than the hardware.
I have heard promises it won't move network irqs but I have seen
the opposite behavior.

> The question is should the kernel work better by default
> *without* irqbalance loaded, or does it not matter?

Good question.  I would aim for the kernel to work better by default.
Ideally we should have a coupling between which sockets applications have
open, which cpus those applications run on, and which core the irqs arrive
at.

> I don't believe we should re-enable the kernel irq balancer, but
> should we consider only setting a single bit in each new interrupt's
> irq affinity?  Doing it with a random spread for the initial affinity
> would be better than setting them all to one.

Not a bad idea.  The practical problem is that we usually have the irqs
setup before we have the additional cpus.  But that isn't entirely true,
I'm thinking of mostly pre-acpi rules.  With ACPI we do some kind of
on-demand setup of the gsi in the device initialization.

How irq threads interact also ways in here.

Eric
