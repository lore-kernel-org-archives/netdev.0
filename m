From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 15 Nov 2007 08:40:45 +0100
Message-ID: <473BF7FD.7010403@hartkopp.net>
References: <20071114121339.25823.0@janus.isnogud.escape.de>	<20071114121425.25823.2@janus.isnogud.escape.de> <20071114133837.6b899595@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@gmx.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:58055 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151AbXKOHk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 02:40:56 -0500
In-Reply-To: <20071114133837.6b899595@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>> +#ifdef CONFIG_CAN_DEBUG_CORE
>> +extern void can_debug_skb(struct sk_buff *skb);
>> +extern void can_debug_cframe(const char *msg, struct can_frame *cframe);
>> +#define DBG(fmt, args...)  (DBG_VAR & 1 ? printk( \
>> +					KERN_DEBUG DBG_PREFIX ": %s: " fmt, \
>> +					__func__, ##args) : 0)
>> +#define DBG_FRAME(fmt, cf) (DBG_VAR & 2 ? can_debug_cframe(fmt, cf) : 0)
>> +#define DBG_SKB(skb)       (DBG_VAR & 4 ? can_debug_skb(skb) : 0)
>> +#else
>> +#define DBG(fmt, args...)
>> +#define DBG_FRAME(fmt, cf)
>> +#define DBG_SKB(skb)
>> +#endif
>>     
>
>
> This non-standard debugging seems like it needs a better interface.
> Also, need paren's around (DBG_VAR & 1) and don't use UPPERCASE for
> variable names.
>   

Of course we do not use UPPERCASE variable names ;-)

The DBG_VAR define points to a module specific named debug variable,
e.g. in can-raw :

+#ifdef CONFIG_CAN_DEBUG_CORE
+#define DBG_PREFIX "can-raw"
+#define DBG_VAR    raw_debug
+static int raw_debug;
+module_param_named(debug, raw_debug, int, S_IRUGO);
+MODULE_PARM_DESC(debug, "debug print mask: 1:debug, 2:frames, 4:skbs");
+#endif

This has been introduced in try#10 to have module specific debug
variable names requested by Arnaldo and Dave.

Regarding the paren's: I love adding paren's, Urs doesn't. But in this
case, there should be no reason for them - or am i wrong here?

>
> Output from checkpatch:
>
> WARNING: do not add new typedefs
> #116: FILE: include/linux/can.h:41:
> +typedef __u32 canid_t;
>
> WARNING: do not add new typedefs
> #124: FILE: include/linux/can.h:49:
> +typedef __u32 can_err_mask_t;
>
>   

These definitions are structure definitions and pretty ok for that
reason - we had that discussion.
Please look into include/linux/can.h for details and if it looks ok for
you also then.

> ERROR: use tabs not spaces
> #498: FILE: net/can/af_can.c:159:
> +^I^I^I^I        " not implemented.\n", module_name);$
>   

Oops! Will be fixed.

> WARNING: braces {} are not necessary for single statement blocks
> #1080: FILE: net/can/af_can.c:741:
> +	if (!proto_tab[proto]) {
> +		printk(KERN_ERR "BUG: can: protocol %d is not registered\n",
> +		       proto);
> +	}
>
>   

Dito.

Thanks for the review, Stephen.

I'll go through your other remarks with Urs today.

Oliver.


