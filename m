From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 1/2] genirq: add function to get IRQ edge/level flags
Date: Sat, 13 Apr 2013 03:21:26 +0200
Message-ID: <5168B316.8010801@collabora.co.uk>
References: <1365789943-3812-1-git-send-email-javier.martinez@collabora.co.uk> <1365789943-3812-2-git-send-email-javier.martinez@collabora.co.uk> <51688310.9040008@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Rob Herring <robherring2@gmail.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jon Hunter <jon-hunter@ti.com>,
	devicetree-discuss@lists.ozlabs.org,
	linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:43425 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab3DMBVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 21:21:30 -0400
In-Reply-To: <51688310.9040008@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2013 11:56 PM, Stephen Warren wrote:
> On 04/12/2013 12:05 PM, Javier Martinez Canillas wrote:
> ...
>> So, is better to add an irq_get_trigger_type() function to obtain
>> the edge/level flags for an IRQ.
> 
>> diff --git a/include/linux/irq.h b/include/linux/irq.h
> 
>> +static inline u32 irq_get_trigger_type(unsigned int irq)
>> +{
>> +	struct irq_data *d = irq_get_irq_data(irq);
>> +	return d ? d->state_use_accessors & IRQD_TRIGGER_MASK : 0;
> 
> Should the direct access to d->state_use_accessors be replaced with a
> call to irqd_get_trigger_type()? Perhaps since this is inside the IRQ
> code header, there's no need to use the accessor function?
> 

Yes, it's better to use irqd_get_trigger_type() instead of a direct access to
d->state_use_accessors since that function is inline so it should be the same
performance wise and it will be easier to maintain.

I'll send a v2 changing that.

Thanks a lot and best regards,
Javier
