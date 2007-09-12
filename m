From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 17:39:26 +0100
Message-ID: <46E8163E.1050308@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <20070912.081211.13753718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:41897 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbXILQj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 12:39:29 -0400
In-Reply-To: <20070912.081211.13753718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Thu, 6 Sep 2007 15:16:00 +0100
> 
>> First, do we need to encourage consistency in NAPI poll drivers? A
>> survey of current NAPI drivers shows different strategies being used
>> in their poll(). Some such as r8169 do the napi_complete() if poll()
>> does less work than their allowed budget. Others such as e100 and
>> tg3 do napi_complete() only if they do no work at all.
> 
> Actually, I want to clarify this situation.  In reality these
> drivers are more consistent than different.
> 
> For some chips the cheapest way to figure out if there is more
> RX work is simply to see if the amount of work processed is
> less than "budget".  It's too expensive to recheck the hardware.
> 
> On some chips like tg3, it's extremely cheap to see if new work
> arrived between the completion of processing the RX queue and
> the NAPI completion check, so they do it.

The inconsistencies I see are to do with the conditions that the driver 
chooses to exit polled mode, i.e. doing no work in the poll() versus 
doing less than budget, and whether txdone processing is done in the 
poll or in the interrupt handler. I didn't mean to suggest that 
rechecking for more work just before doing the napi_complete() was an 
example of inconsistency.

The rest of the RFC talks about polling the device while it might be 
idle. The overhead of checking for work varies for each system / device 
as you say. Where it is expensive, the driver could optimize that case.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

