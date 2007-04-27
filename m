From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Fri, 27 Apr 2007 08:27:10 -0400
Message-ID: <4631EC1E.4030401@garzik.org>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net> <4630B76C.7070603@nvidia.com> <4630EE50.4000109@garzik.org> <4630BCD0.9040702@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, mingo@elte.hu
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38949 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733AbXD0M1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 08:27:20 -0400
In-Reply-To: <4630BCD0.9040702@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> 
> 
> Jeff Garzik wrote:
>> Ayaz Abdulla wrote:
>>
>>> I don't see why the NAPI handler needs to process tx packets. The ISR 
>>> will handle all tx processing.
>>
>>
>> It is a design choice, not a requirement.
>>
>> Moving non-RX interrupt processing to the NAPI handler can help as 
>> loads increase.  The basic idea is to do as much work as possible in 
>> the NAPI handler with NIC interrupts masked.  That mitigates global 
>> system per-interrupt overhead even more than an only-RX NAPI scheme.
>>
>> Several net drivers do TX completion handling in the NAPI handler.
> 
> Ok. In that case, the patch needs to be improved.
> 
> The following needs to be done when NAPI is enabled:
> - remove the tx handling within the ISRs
> - mask off the tx interrupts within the ISRs that handle tx processing
> - re-enable tx interrupts within the NAPI handler
> - add tx handling within the NAPI handler (this patch covers it)

Agreed.

	Jeff



