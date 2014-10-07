From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [net v2 3/8] net/fsl_pq_mdio: Replace spin_event_timeout() with
 arch independent
Date: Tue, 7 Oct 2014 15:16:10 +0300
Message-ID: <5433D98A.2060904@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
 <1412667875-18225-4-git-send-email-claudiu.manoil@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D174C5BAC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0103.outbound.protection.outlook.com ([157.56.111.103]:24256
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753400AbaJGMQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 08:16:34 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C5BAC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/2014 11:12 AM, David Laight wrote:
> From: netdev-owner@vger.kernel.
>> spin_event_timeout() is PPC dependent, use an arch independent
>> equivalent instead.
>
> I think you should white a local function/#define that expands to spin_event_timeout()
> on ppc and to the code below you are substituting on other architectures.
>
>>   	/* Wait for the transaction to finish */
>> -	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
>> -				    MIIMIND_BUSY), MII_TIMEOUT, 0);
>> +	timeout = MII_TIMEOUT;
>> +	while ((ioread32be(&regs->miimind) & MIIMIND_BUSY) && timeout) {
>> +		cpu_relax();
>> +		timeout--;
>> +	}
>
> 	David
>
>
>

Hi David,

This point is debatable. Still better than adding a new local function 
would be to provide an implementation for spin_even_timeout() for ARM.
But it is not the place of the ethernet driver to provide an 
implementation of spin_event_timeout() on ARM.
Instead, I opted to simplify the busy wait/ timeout mechanism
in the driver using a simple and arch independent implementation 
replacing the PPC specific spin_event_timeout().  This timeout 
implementation, open-coded as a while() loop, is commonly used by other 
drivers too and I think that for this particular driver (fsl_pq_mdio) it 
is good enough to do the job, while keeping the code simple and 
portable.  It may not be as precise as spin_event_timeout() on PPC, but 
good enough.

Thanks,
Claudiu
