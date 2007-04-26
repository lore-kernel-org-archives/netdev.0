From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Thu, 26 Apr 2007 10:53:04 -0400
Message-ID: <4630BCD0.9040702@nvidia.com>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net> <4630B76C.7070603@nvidia.com> <4630EE50.4000109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, mingo@elte.hu
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:1676 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031429AbXDZShD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 14:37:03 -0400
In-Reply-To: <4630EE50.4000109@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jeff Garzik wrote:
> Ayaz Abdulla wrote:
> 
>> I don't see why the NAPI handler needs to process tx packets. The ISR 
>> will handle all tx processing.
> 
> 
> It is a design choice, not a requirement.
> 
> Moving non-RX interrupt processing to the NAPI handler can help as loads 
> increase.  The basic idea is to do as much work as possible in the NAPI 
> handler with NIC interrupts masked.  That mitigates global system 
> per-interrupt overhead even more than an only-RX NAPI scheme.
> 
> Several net drivers do TX completion handling in the NAPI handler.

Ok. In that case, the patch needs to be improved.

The following needs to be done when NAPI is enabled:
- remove the tx handling within the ISRs
- mask off the tx interrupts within the ISRs that handle tx processing
- re-enable tx interrupts within the NAPI handler
- add tx handling within the NAPI handler (this patch covers it)

> 
>     Jeff
> 
> 

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
