From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 19 Dec 2004 17:43:04 -0500
Message-ID: <41C603F8.9030705@pobox.com>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com> <1103484552.1046.155.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
        Paul Jakma <paul@clubi.ie>
In-Reply-To: <1103484552.1046.155.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2004-12-15 at 10:03, Thomas Spatzier wrote:
> 
> 
>>jamal <hadi@cyberus.ca> wrote on 15.12.2004 14:50:27:
>>
>>
>>>When you netif_stop_queue you should never receive packets anymore
>>>at the device level. If you receive any its a bug and you should drop
>>>them and bitch violently. In other words i think what you have at the
>>>moment is bandaid not the solution.
>>
>>When we do a netif_stop_queue, we do not get any more packets.
>>So this behaviour is ok. The problem is that the socket write
>>queues fill up then and get blocked as soon as they are full.
>>
> 
> 
> This is the strange part. Anyone still willing to provide a sample
> program that hangs?
> 
> 
>>>Can you describe how your driver uses the netif_start/stop/wake
>>>interfaces?
>>
>>Before the patch we are talking about:
>>When we detect a cable pull (or something like this) we call
>>netif_stop_queue and set switch off the IFF_RUNNING flag.
>>Then when we detect that the cable is plugged in again, we
>>call netif_wake_queue and switch the IFF_RUNNING flag on.
>>
> 
> 
> Not too bad except user space doesnt get async notification.
> 
> 
>>And with the patch:
>>On cable pull we switch off IFF_RUNNING and call
>>netif_carrier_off. We still get packets but drop them.
>>When the cable is plugged in we switch on IFF_RUNNING and
>>call netif_carrier_on.
> 
> 
> Ok, thats something you need to change.
> Why you are setting that IFF_RUNNING flag?
> Look at e1000 they do it right there. 
> 
> On link up:
> 	netif_carrier_on(netdev);
> 	netif_wake_queue(netdev);
> On Link Down:
> 	netif_carrier_off(netdev); // wonder if these need swapping
> 	netif_stop_queue(netdev);
> 
> Still, I think we need to resolve the original problem.
> And I have a feeling we wont be seeing any program which 
> reproduces it ;->


I've been watching this thread, and am still waiting to see a good, 
isolated test case.

My initial reaction was based on an observation that
(a) the proposed s390 change creates a CPU cycle soaker, a /dev/null for 
skbs.
(b) it really sounds like the userland program is doing something broken

Even if (b) is not true, the change is unacceptable due to (a) regardless.

	Jeff
