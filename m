From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Fri, 01 Apr 2005 10:22:51 -0800
Message-ID: <424D917B.2060108@hp.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com>	<1112305084.1073.94.camel@jzny.localdomain> <424C7CDC.8050801@hp.com>	<1112312206.1096.25.camel@jzny.localdomain> <424C90DA.7030600@hp.com> <1112318229.1090.63.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <1112318229.1090.63.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>The main idea behind TOPS and prior to that IPS was to spread-out 
>>the processing of packets across as many CPUs as we could, as "correctly" as we 
>>could.
> 
> 
> Very very hard to do. 

Why do you say that?  "Correct" can be defined as either the same CPU for each 
packet in a given flow (IPS) or the same CPU as last accessed the endpoint (TOPS).

> Isnt MSI supposed to give you ability such that a 
> NIC can pick a CPU to interupt? That would help in a small way

That gives the NIC the knowledge of how to direct to a CPU, but as you know does 
not tell it how to decide where.  Since I doubt that the NIC wants to reach-out 
and touch connection state in the host (nor I suppose do we want it to either) 
the best a NIC with MSI could do would be IPS

>>TOPS lets the process (I suppose the scheduler really) decide where some of the 
>>processing for the packet will happen - the part after the handoff.
>>
> 
> I think this last part should be easy to do - but perhaps the expense of
> landing on the wrong CPU may override any benefits perceived.

Unless one has a scheduler that likes to migrate processes, the chances of 
landing on the wrong CPU are minimal and shortlived, and overall, the chances of 
being right are greater than if not doing anything and sticking with the 
interrupt CPU. (Handwaving based on experience-driven intuition and a bit of 
math as one increases the CPU count)  This is all on the premis that one is 
running with numNIC << numCPU.  With numNIC == numCPU one does things as seen in 
certain networking-intensive benchmarks :)

rick jones
