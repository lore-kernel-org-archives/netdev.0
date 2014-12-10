From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v7 2/3] net: Add Keystone NetCP ethernet driver
Date: Wed, 10 Dec 2014 16:31:02 -0500
Message-ID: <5488BB96.9070609@ti.com>
References: <1417556503-22290-1-git-send-email-m-karicheri2@ti.com> <1417556503-22290-3-git-send-email-m-karicheri2@ti.com> <20141209.131053.2026868499542642866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141209.131053.2026868499542642866.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/09/2014 01:10 PM, David Miller wrote:
> From: Murali Karicheri<m-karicheri2-l0cyMroinI0@public.gmane.org>
> Date: Tue, 2 Dec 2014 16:41:42 -0500
>
>> +static void set_pkt_info_le(u32 buff, u32 buff_len, u32 ndesc,
>> +			    struct knav_dma_desc *desc)
>> +{
>> +	desc->buff_len = cpu_to_le32(buff_len);
>> +	desc->buff = cpu_to_le32(buff);
>> +	desc->next_desc = cpu_to_le32(ndesc);
>> +}
>
> The members of knav_dma_desc are "u32", so you are going to get tons of
> static checker warnings from trying to assign cpu_to_le32()'s result
> (which is a le32) into them.
David,

Thanks for your comment.

Are you referring to the static code analyser sparse that is invoked 
through?

make C=1 CHECK=sparse

I am running it now.

I started a build of v3.18-rc7 with this option and seeing a lot of
warnings. Am I using the right tool? A snapshot of the output is below

   CHECK   drivers/clk/clk.c
include/linux/err.h:40:16: warning: testing a 'safe expression'
include/linux/err.h:40:16: warning: testing a 'safe expression'
include/linux/err.h:40:16: warning: testing a 'safe expression'
include/linux/err.h:40:16: warning: testing a 'safe expression'
drivers/clk/clk.c:2263:5: warning: symbol '__clk_get' was not declared. 
Should it be static?
drivers/clk/clk.c:2274:6: warning: symbol '__clk_put' was not declared. 
Should it be static?
drivers/clk/clk.c:2647:37: warning: incorrect type in assignment 
(different modifiers)
drivers/clk/clk.c:2647:37:    expected void ( *[usertype] clk_init_cb )( 
... )
drivers/clk/clk.c:2647:37:    got void const *const data
drivers/clk/clk.c:67:22: warning: context imbalance in 'clk_enable_lock' 
- wrong count at exit
drivers/clk/clk.c:92:9: warning: context imbalance in 
'clk_enable_unlock' - unexpected unlock
   CC      drivers/clk/clk.o
   CHECK   drivers/clk/clk-divider.c
drivers/clk/clk-divider.c:362:9: warning: context imbalance in 
'clk_divider_set_rate' - different lock contexts for basic block
   CC      drivers/clk/clk-divider.o
   CHECK   drivers/clk/clk-fixed-factor.c
   CC      drivers/clk/clk-fixed-factor.o
   CHECK   drivers/clk/clk-fixed-rate.c
   CC      drivers/clk/clk-fixed-rate.o
   CHECK   drivers/clk/clk-gate.c
drivers/clk/clk-gate.c:71:9: warning: context imbalance in 
'clk_gate_endisable' - different lock contexts for basic block
   CC      drivers/clk/clk-gate.o
   CHECK   drivers/clk/clk-mux.c
drivers/clk/clk-mux.c:69:12: warning: context imbalance in 
'clk_mux_set_parent' - different lock contexts for basic block
   CC      drivers/clk/clk-mux.o
   CHECK   drivers/clk/clk-composite.c
   CC      drivers/clk/clk-composite.o
   CHECK   drivers/clk/clk-fractional-divider.c
drivers/clk/clk-fractional-divider.c:36:9: warning: context imbalance in 
'clk_fd_recalc_rate' - different lock contexts for basic block
drivers/clk/clk-fractional-divider.c:65:12: warning: context imbalance 
in 'clk_fd_set_rate' - different lock contexts for basic block
   CC      drivers/clk/clk-fractional-divider.o
   CHECK   drivers/clk/clk-gpio-gate.c
drivers/clk/clk-gpio-gate.c:189:13: warning: symbol 
'of_gpio_gate_clk_setup' was not declared. Should it be static?
   CC      drivers/clk/clk-gpio-gate.o
   CHECK   drivers/clk/clk-conf.c
   CC      drivers/clk/clk-conf.o
   CHECK   drivers/clk/keystone/pll.c
   CC      drivers/clk/keystone/pll.o
   CHECK   drivers/clk/keystone/gate.c
drivers/clk/keystone/gate.c:118:12: warning: context imbalance in 
'keystone_clk_enable' - different lock contexts for basic block
drivers/clk/keystone/gate.c:148:9: warning: context imbalance in 
'keystone_clk_disable' - different lock contexts for basic block
   CC      drivers/clk/keystone/gate.o
   LD      drivers/clk/keystone/built-in.o
   LD      drivers/clk/built-in.o
   CHECK   drivers/clocksource/clksrc-of.c
drivers/clocksource/clksrc-of.c:37:27: warning: incorrect type in 
assignment (different modifiers)
drivers/clocksource/clksrc-of.c:37:27:    expected void ( *[usertype] 
init_func )( ... )
drivers/clocksource/clksrc-of.c:37:27:    got void const *const data
   CC      drivers/clocksource/clksrc-of.o
   CHECK   drivers/clocksource/mmio.c
   CC      drivers/clocksource/mmio.o
   CHECK   drivers/clocksource/arm_arch_timer.c
   CC      drivers/clocksource/arm_arch_timer.o
   CHECK   drivers/clocksource/dummy_timer.c
   CC      drivers/clocksource/dummy_timer.o
   CHECK   drivers/clocksource/timer-keystone.c
   CC      drivers/clocksource/timer-keystone.o
   LD      drivers/clocksource/built-in.o
   LD      drivers/crypto/built-in.o
   CHECK   drivers/dma/dmaengine.c
   CC      drivers/dma/dmaengine.o
   CHECK   drivers/dma/virt-dma.c
drivers/dma/virt-dma.c:22:14: warning: symbol 'vchan_tx_submit' was not 
declared. Should it be static?
   CC      drivers/dma/virt-dma.o
   CHECK   drivers/dma/of-dma.c
   CC      drivers/dma/of-dma.o
   CHECK   drivers/dma/edma.c
drivers/dma/edma.c:560:32: warning: symbol 'edma_prep_dma_memcpy' was 
not declared. Should it be static?
drivers/dma/edma.c:1099:6: warning: symbol 'edma_filter_fn' was not 
declared. Should it be static?





-- 
Murali Karicheri
Linux Kernel, Texas Instruments
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
