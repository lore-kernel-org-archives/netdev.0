From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: 31 Mar 2005 20:17:10 -0500
Message-ID: <1112318229.1090.63.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <20050331120410.7effa94d@dxpl.pdx.osdl.net>
	 <1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com>
	 <1112305084.1073.94.camel@jzny.localdomain> <424C7CDC.8050801@hp.com>
	 <1112312206.1096.25.camel@jzny.localdomain>  <424C90DA.7030600@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <424C90DA.7030600@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 19:07, Rick Jones wrote:

> Ah, I wasn't clear - would someone doing serious TCP want to have the interrupts 
> of a NIC go to a specific CPU.
> 

Not sure i followed:
Your TCP app (server probably) is running on CPU X;
You therefore want to tie the NIC which it goes out on the same CPU X?

AFAIK, Linux scheduler will reschedule a process on the last CPU it was
running on if possible - So if you bind a NIC to some CPU it is likely
that the CPU will also run the process. Just handwaving - never tried to
observe.
You could bind processes to CPUs (process affinity) from user space but
then also make sure you bind CPU-NIC statically

> More expensive than if one were lucky enough to have the interrupt on the 
> "right" CPU in the first place, but as the CPU count goes-up, the chances of 
> that go down.

Indeed.

> The main idea behind TOPS and prior to that IPS was to spread-out 
> the processing of packets across as many CPUs as we could, as "correctly" as we 
> could.

Very very hard to do. Isnt MSI supposed to give you ability such that a 
NIC can pick a CPU to interupt? That would help in a small way

>   Lots of small packets meant/means that a NIC could saturate its 
> interrupt CPU before the NIC was saturated.  You don't necessarily see that on 
> say single-instance netperf TCP_STREAM (or basic FTP) testing, but certainly can 
> on aggregate netperf TCP_RR testing.
> 
> IPS, being driven by the packet header info, was good enough for simple 
> benchmarking, but once you had more than one connection per process/thread that 
> wasn't going to cut it, and even with one connection per process telling the 
> process where it should run wasn't terribly easy :)   It wasn't _that_ much more 
> expensive than the queueing already happening - IPS was when HP-UX networking 
> was BSDish and it was done when things were being queued to the netisr queue(s).
> 
> TOPS lets the process (I suppose the scheduler really) decide where some of the 
> processing for the packet will happen - the part after the handoff.
> 

I think this last part should be easy to do - but perhaps the expense of
landing on the wrong CPU may override any benefits perceived.

cheers,
jamal
