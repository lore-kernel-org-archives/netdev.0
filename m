From: jamal <hadi@cyberus.ca>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: 25 Jan 2004 14:14:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075058082.1746.85.camel@jzny.localdomain>
References: <002501c3e2b5$543c45e0$0400a8c0@S2IOtech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <002501c3e2b5$543c45e0$0400a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-01-24 at 15:04, Leonid Grossman wrote:

> These schemes could be complimentary, right now we do see that different
> thresholds need to be programmed for regular and Jumbo traffic.
> 
> One thing I did not mention is that our ASIC supports several
> utilization thresholds on per interrupt basis (up to 64 MSI-X
> interrupts). There are also independent tx and rx queues, and each can
> have it's own interrupt. There is a pretty large number of parameters
> that traffic could be steered upon, packet size is one of them.
> 

Would be interesting to see what these queue selection parameters are.
For example, an extremely important thing to avoid is reordering of
packets. You reorder packets on a TCP flow and you perfomance goes
beserk.
 
> So, if you want to have different interrupt moderation schemes for
> different packet sizes, you just need to steer packets to separate
> queues based upon size, and then assign a separate MSI interrupt to
> these queues and set different utilization thresholds for different
> interrupts. At any given workload, you will be getting interrupts at
> different rate for small and for big packets.

Does sound interesting, but i am suspcious about reordering; i.e you
dont want a 64 byte packet from one flow to be in a different queue
than another which is 1500 bytes. The 2 packet must be processed
strictly in FIFO manner.

> Anyway, you are right there are many interrupt moderation schemes that
> host driver can deploy, our goal was to provide a flexible hardware
> assist. 

So is it possible to program it such that if a threshold interupt rate
is crossed it adjusts its mitigation values? actually i should say its
the second order effect that is of interest to the threshold i.e the
integral of the interupt arrival rate.

cheers,
jamal
