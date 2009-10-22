From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Irq architecture for multi-core network driver.
Date: Thu, 22 Oct 2009 15:24:24 -0700
Message-ID: <4AE0DB98.1000101@caviumnetworks.com>
References: <4AE0D14B.1070307@caviumnetworks.com> <4AE0D72A.4090607@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips <linux-mips@linux-mips.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752276AbZJVWYs@vger.kernel.org>
In-Reply-To: <4AE0D72A.4090607@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:
> On 10/22/2009 03:40 PM, David Daney wrote:
> 
>> The main problem I have encountered is how to fit the interrupt
>> management into the kernel framework.  Currently the interrupt source
>> is connected to a single irq number.  I request_irq, and then manage
>> the masking and unmasking on a per cpu basis by directly manipulating
>> the interrupt controller's affinity/routing registers.  This goes
>> behind the back of all the kernel's standard interrupt management
>> routines.  I am looking for a better approach.
>>
>> One thing that comes to mind is that I could assign a different
>> interrupt number per cpu to the interrupt signal.  So instead of
>> having one irq I would have 32 of them.  The driver would then do
>> request_irq for all 32 irqs, and could call enable_irq and disable_irq
>> to enable and disable them.  The problem with this is that there isn't
>> really a single packets-ready signal, but instead 16 of them.  So If I
>> go this route I would have 16(lines) x 32(cpus) = 512 interrupt
>> numbers just for the networking hardware, which seems a bit excessive.
> 
> Does your hardware do flow-based queues?  In this model you have
> multiple rx queues and the hardware hashes incoming packets to a single
> queue based on the addresses, ports, etc. This ensures that all the
> packets of a single connection always get processed in the order they
> arrived at the net device.
> 

Indeed, this is exactly what we have.


> Typically in this model you have as many interrupts as queues
> (presumably 16 in your case).  Each queue is assigned an interrupt and
> that interrupt is affined to a single core.

Certainly this is one mode of operation that should be supported, but I 
would also like to be able to go for raw throughput and have as many 
cores as possible reading from a single queue (like I currently have).

> 
> The intel igb driver is an example of one that uses this sort of design.
> 

Thanks, I will look at that driver.

David Daney
