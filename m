From: Pantelis Antoniou <panto@intracom.gr>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Thu, 12 May 2005 09:08:47 +0300
Message-ID: <4282F2EF.4020307@intracom.gr>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>	<1110334456.32556.21.camel@gaston>	<20050308194229.41c23707.davem@davemloft.net>	<1110340214.32524.32.camel@gaston>	<57a429f8eb807987d88b06129861d507@freescale.com>	<4230D1AC.5070506@katalix.com>	<ba5d844255b5ba76b2685f9397faf689@freescale.com>	<423734FB.40101@katalix.com>	<96c50184a02557c88dee0e6d17f3a539@freescale.com>	<42625DDB.4090600@katalix.com>
	<30d87aabd768216ef8bee800f3e09b9e@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <30d87aabd768216ef8bee800f3e09b9e@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> 
> On Apr 17, 2005, at 08:00, James Chapman wrote:
> 
>> Andy Fleming wrote:
>>
>>> Ok, here's the new patch with changes suggested by James Chapman:
>>
>>
>> I guess I still have questions about the way interrupts are used.
>>
>> Using an interrupt to schedule a work queue which then sets a variable
>> that is used by a timer seems odd. Why not do all the work in the work
>> queue and schedule it from the interrupt handler or timer?
> 
> 
> Ok, I've set up a new system for handling interrupts.  There are now two 
> "special" interrupt values, PHY_POLL, and PHY_IGNORE_INTERRUPT.  The 
> first one is used to indicate that the PHY layer will poll the PHY for 
> state changes, and won't enable interrupts.  The second indicates that 
> the PHY layer will neither poll, nor enable interrupts, and thus will 
> allow the driver to handle interrupts.  The PHY layer will still operate 
> its state machine, though.
> 
> The driver must insure a couple things:
> 
> 1) It must set phydev->state to PHY_CHANGELINK
> 2) It must do that in a work queue (or other non-interrupt time)
> 
> The first one tells the PHY layer that the link state changed (it has to 
> grab a lock to do this).  The second one is required in order to 
> properly take the lock.
> 
>>
>> Also, did you mean to leave the #if 0 code in davicom.c?
> 
> 
> For now.  It worked around a problem some people were reporting, so I'd 
> like to see if they report it again now that the code's out.  If so, 
> they have a fairly easy fix, and I can reinsert it (or at least 
> reevaluate it) in the future.
> 
>>
>> /james
> 
> 
> Andy
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Linuxppc-embedded mailing list
> Linuxppc-embedded@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-embedded

Hi Andy.

Mind taking a look at the combined FEC/FCC driver I've posted and
comment on how hard it'll be to use your PAL? I'd be especially
interested at any API mismatches, and problems you might find.

Regards

Pantelis
