From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 5/7] [PATCH 5/8] can: SJA1000 generic platform bus
 driver
Date: Fri, 15 May 2009 15:12:25 +0200
Message-ID: <4A0D6A39.2000104@grandegger.com>
References: <20090512092757.048938233@denx.de> <20090512092757.894204198@denx.de> <20090514064633.GT29278@pengutronix.de> <4A0D374A.8080006@grandegger.com> <20090515120711.GE26519@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42800 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531AbZEONM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 09:12:29 -0400
In-Reply-To: <20090515120711.GE26519@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> On Fri, May 15, 2009 at 11:35:06AM +0200, Wolfgang Grandegger wrote:
>> Hi Sascha,
>>
>> Sascha Hauer wrote:
>>> Hi Wolfgang,
[...}
>>>> +	irq = res_irq->start;
>>>> +	if (res_irq->flags & IRQF_TRIGGER_MASK)
>>>> +		set_irq_type(irq, res_irq->flags & IRQF_TRIGGER_MASK);
>>> You shouldn't use set_irq_type on not yet requested irqs but instead
>>> pass the flags to the real driver and pass them in request_irq.
>> Why? I would require an extra member in the struct sja1000_priv.
> 
> You change a resource you do not own. What if request_irq returns with
> -EBUSY? You already screwed up any other potential user.

OK, I added irq_flags to struct sja1000_priv, which  will then be used
by the request_irq(). The driver must to set it appropriately, including
IRQF_SHARED. This also fixes the problem, that drivers used IRQF_SHARED
without reason.

Thanks,

Wolfgang.
