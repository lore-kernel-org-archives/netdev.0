From: jamal <hadi@cyberus.ca>
Subject: Re: Ethernet bridge performance
Date: 07 Aug 2003 15:21:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060284094.1024.36.camel@jzny.localdomain>
References: <3F3217E7.2080903@allot.com> <3F3284EA.5050406@candelatech.com>
	 <3F328A0F.3040005@allot.com>  <16178.41976.3643.584516@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Felix Radensky <felix@allot.com>, Ben Greear <greearb@candelatech.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16178.41976.3643.584516@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Actually seems his biggest problem is he is not running
the NAPI driver

cheers,
jamal

On Thu, 2003-08-07 at 15:09, Robert Olsson wrote:
> Felix Radensky writes:
>  > Thanks for your help, Ben. What is skb-recycle patch
>  > and where can I find it ?
>  
>  It's experimental and not updated for almost a year and current 
>  implementation does not add anything to SMP. Got some idea how
>  to improve this... but try to keep to slab as long as possible 
>  it has been improved.
> 
>  Routing/bridging on SMP has affinty problem. If you are passing
>  skb's say from eth0 to eth1 and they are bound on different CPU's
>  you get cache boucing since the TX-interrupts come on another CPU.
> 
>  In a recent test with pktgen:
>  300 kpps with TX interrupts on same CPU as sender.
>  198 kpps with TX intr on different CPU as sender.
> 
>  Recycling tries to address this but current implementation fails
>  as said.
> 
>  But you are probably hit by something else... Check were the drops 
>  happens qdisc?. NIC ring RX/TX size, Number of interrupts. ksoftird 
>  priority, link HW_FLOW control, checksumming, affinity etc. 
> 
>  
>  Cheers.
> 						--ro
> 
> 
