From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH 1/2] genirq: add function to get IRQ edge/level flags
Date: Fri, 12 Apr 2013 15:56:32 -0600
Message-ID: <51688310.9040008@wwwdotorg.org>
References: <1365789943-3812-1-git-send-email-javier.martinez@collabora.co.uk> <1365789943-3812-2-git-send-email-javier.martinez@collabora.co.uk>
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
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1365789943-3812-2-git-send-email-javier.martinez@collabora.co.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/12/2013 12:05 PM, Javier Martinez Canillas wrote:
...
> So, is better to add an irq_get_trigger_type() function to obtain
> the edge/level flags for an IRQ.

> diff --git a/include/linux/irq.h b/include/linux/irq.h

> +static inline u32 irq_get_trigger_type(unsigned int irq)
> +{
> +	struct irq_data *d = irq_get_irq_data(irq);
> +	return d ? d->state_use_accessors & IRQD_TRIGGER_MASK : 0;

Should the direct access to d->state_use_accessors be replaced with a
call to irqd_get_trigger_type()? Perhaps since this is inside the IRQ
code header, there's no need to use the accessor function?
