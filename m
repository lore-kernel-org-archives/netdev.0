From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Sun, 05 Apr 2009 09:13:27 -0500
Message-ID: <49D8BC87.8030401@codemonkey.ws>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <200904011638.45135.rusty@rustcorp.com.au> <49D391F5.4080700@codemonkey.ws> <200904051314.23170.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200904051314.23170.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Thursday 02 April 2009 02:40:29 Anthony Liguori wrote:
>   
>> Rusty Russell wrote:
>>     
>>> As you point out, 350-450 is possible, which is still bad, and it's at least
>>> partially caused by the exit to userspace and two system calls.  If virtio_net
>>> had a backend in the kernel, we'd be able to compare numbers properly.
>>>       
>> I doubt the userspace exit is the problem.  On a modern system, it takes 
>> about 1us to do a light-weight exit and about 2us to do a heavy-weight 
>> exit.  A transition to userspace is only about ~150ns, the bulk of the 
>> additional heavy-weight exit cost is from vcpu_put() within KVM.
>>     
>
> Just to inject some facts, servicing a ping via tap (ie host->guest then
> guest->host response) takes 26 system calls from one qemu thread, 7 from
> another (see strace below). Judging by those futex calls, multiple context
> switches, too.
>   

N.B. we're not optimized for latency today.  With the right 
infrastructure in userspace, I'm confident we could get this down.

What we need is:

1) Lockless MMIO/PIO dispatch (there should be two IO registration 
interfaces, a new lockless one and the legacy one)
2) A virtio-net thread that's independent of the IO thread.

It would be interesting to count the number of syscalls required in the 
lguest path since that should be a lot closer to optimal.

Regards,

Anthony Liguori

