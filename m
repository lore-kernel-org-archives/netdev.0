From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 23:29:13 -0700
Message-ID: <46440D39.8060207@gmail.com>
References: <OF04243E77.B5369513-ON652572D8.00213C30-652572D8.00218BE4@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sceptre.pobox.com ([207.106.133.20]:32820 "EHLO
	sceptre.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759451AbXEKG3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:29:03 -0400
In-Reply-To: <OF04243E77.B5369513-ON652572D8.00213C30-652572D8.00218BE4@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
>> What about a race between trying to reacquire queue_lock and another
>> failed transmit?
> 
> That is not possible too. I hold the QDISC_RUNNING bit in dev->state and
> am the only sender for this device, so there is no other failed transmit.
> Also, on failure of dev_hard_start_xmit, qdisc_restart will spin for the
> queue lock (which could be held quickly by enqueuer's), and q->requeue()
> skbs to the head of the list.

I have to claim incomplete familiarity for the code. But still, if 
you're out there running with no locks for a period, there's no 
assumption you can make. The "lock could be held quickly" assertion is a 
fallacy.

> 
> Thanks,
> 
> - KK
> 
