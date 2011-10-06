From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 06 Oct 2011 09:02:37 +0200
Message-ID: <4E8D528D.8020607@hartkopp.net>
References: <4E8C78E8.3010605@hartkopp.net> <20111005155127.GB13794@pengutronix.de> <4E8C8175.2040202@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:37534 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab1JFHCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 03:02:49 -0400
In-Reply-To: <4E8C8175.2040202@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/11 18:10, Oliver Hartkopp wrote:

> On 10/05/11 17:51, Wolfram Sang wrote:

>>> +		/* zero accidentally copied register content at odd DLCs */
>>> +		if (frame->can_dlc & 1)
>>> +			frame->data[frame->can_dlc] = 0;
>>>  	}
>>>  
>>>  	out_8(&regs->canrflg, MSCAN_RXF);
>>
>> Nice catch, but wouldn't it be more elegant to never have an invalid byte
>> in the first place?
>>
>> if (can_dlc & 1)
>> 	*payload = in_be16() & mask;
>>
> 
> 
> Hm, then i would rather think about changing the for() statement and to read
> byte-by-byte instead of the current in_be16() usage with the 16bit access
> drawbacks ...
> 


I think if one would like to rework the 16bit register access (which is used
in the rx path /and/ in the tx path also) this should go via net-next after
some discussion and testing.

IMHO this fix is small and clear and especially not risky. I wonder if
reworking the 16 bit register access is worth the effort?

Regards,
Oliver
