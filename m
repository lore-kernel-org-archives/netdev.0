From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Sat, 24 Jan 2004 12:04:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002501c3e2b5$543c45e0$0400a8c0@S2IOtech.com>
References: <1074967227.1732.15.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <hadi@cyberus.ca>
In-Reply-To: <1074967227.1732.15.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca] 
> Sent: Saturday, January 24, 2004 10:00 AM
> To: Leonid Grossman
> Cc: netdev@oss.sgi.com
> Subject: RE: FW: Submission for S2io 10GbE driver
> 
> 
> On Sat, 2004-01-24 at 00:10, Leonid Grossman wrote:
> 
> > > - Adaptive Interrupt Coalescence
> > 
> > There are several interrupt schemes, in the utilization scheme the 
> > device can be programmed to automatically adjust interrupt 
> rate based 
> > upon link utilization, independently for tx and rx interrupts. For 
> > instance, if the utilization is in single percentage digits 
> then the 
> > device can be programmed to get an interrupt per every packet since 
> > interrupt rate doesn't matter much; If the utilization gets 
> closer to 
> > 100%, it will probably make sense to program device for, say, one 
> > interrupt per 200 packets - the number will somewhat vary for 
> > different systems and packet sizes.
> > 
> 
> How effective is this?

Today with a legacy pin iterrupts it's reasonably efective, and I have
higher hopes for MSI and MSI-X when systems and the OS starts supporting
it.

> Example you could easily fill up a link with larger packets (less
> interupts) than with smaller packets (more interupts). The 
> latter overloads the system more. 
> getting feedback from the system (which you can in Linux) and 
> adjusting the rate that way would be more effective it seems. 

These schemes could be complimentary, right now we do see that different
thresholds need to be programmed for regular and Jumbo traffic.

One thing I did not mention is that our ASIC supports several
utilization thresholds on per interrupt basis (up to 64 MSI-X
interrupts). There are also independent tx and rx queues, and each can
have it's own interrupt. There is a pretty large number of parameters
that traffic could be steered upon, packet size is one of them.

So, if you want to have different interrupt moderation schemes for
different packet sizes, you just need to steer packets to separate
queues based upon size, and then assign a separate MSI interrupt to
these queues and set different utilization thresholds for different
interrupts. At any given workload, you will be getting interrupts at
different rate for small and for big packets.

Anyway, you are right there are many interrupt moderation schemes that
host driver can deploy, our goal was to provide a flexible hardware
assist. 

Thanks, Leonid



> Adjusting interupt rates based on a moving window averaging 
> of the packet arrival rate would also be useful.
> 
> cheers,
> jamal
> 
