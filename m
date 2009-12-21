From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 21 Dec 2009 17:43:09 +0200
Message-ID: <4B2F978D.7010602@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756088AbZLUPnl@vger.kernel.org>
In-Reply-To: <4B2F9582.5000002@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/21/2009 05:34 PM, Gregory Haskins wrote:
>
>> I think it would be fair to point out that these patches have been objected to
>> by the KVM folks quite extensively,
>>      
> Actually, these patches have nothing to do with the KVM folks.  You are
> perhaps confusing this with the hypervisor-side discussion, of which
> there is indeed much disagreement.
>    

This is true, though these drivers are fairly pointless for 
virtualization without the host side support.

I did have a few issues with the guest drivers:
- the duplication of effort wrt virtio.  These drivers don't cover 
exactly the same problem space, but nearly so.
- no effort at scalability - all interrupts are taken on one cpu
- the patches introduce a new virtual interrupt controller for dubious 
(IMO) benefits

>  From my research, the reason why virt in general, and KVM in particular
> suffers on the IO performance front is as follows: IOs
> (traps+interrupts) are more expensive than bare-metal, and real hardware
> is naturally concurrent (your hbas and nics are effectively parallel
> execution engines, etc).
>
> Assuming my observations are correct, in order to squeeze maximum
> performance from a given guest, you need to do three things:  A)
> eliminate as many IOs as you possibly can, B) reduce the cost of the
> ones you can't avoid, and C) run your algorithms in parallel to emulate
> concurrent silicon.
>    

All these are addressed by vhost-net without introducing new drivers.

-- 
error compiling committee.c: too many arguments to function
