From: "Gole, Anant" <anantgole@ti.com>
Subject: RE: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Fri, 28 Aug 2009 18:43:13 +0530
Message-ID: <2A3DCF3DA181AD40BDE86A3150B27B6B02F6211049@dbde02.ent.ti.com>
References: <1251458282-4674-1-git-send-email-anantgole@ti.com>
 <4A97D146.5050806@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41445 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbZH1NNa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 09:13:30 -0400
In-Reply-To: <4A97D146.5050806@hartkopp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: Oliver Hartkopp [mailto:socketcan@hartkopp.net]
>Sent: Friday, August 28, 2009 6:15 PM
>To: Gole, Anant
>Cc: socketcan-core@lists.berlios.de; netdev@vger.kernel.org; Wolfgang
>Grandegger
>Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
>
>Anant Gole wrote:
>> TI HECC (High End CAN Controller) module is found on many TI devices. It
>has
>> 32 harwdare mailboxes with full implementation of CAN protocol version
>2.0B
>> and bus speeds up to 1Mbps. The module specifications are available at TI
>web
>> <http://www.ti.com>.
>>
>> This driver is tested on OMAP3517 EVM. Suspend/Resume not tested as yet.
>>
>
>Hello Anant,
>
>some nitpicking first:

No issues at all. The driver code will only get better when more people will review it and that is good.

>
>> +#include <linux/can/platform/ti_hecc_platform.h>
>
>Please use
>
>linux/can/platform/ti_hecc.c

are you suggesting to keep the platform file name as ti_hecc.h?

>
>following the other drivers.
>
>> +
>> +#define DRV_NAME "TI HECC"
>
>DRV_NAME "ti_hecc"

Agreed. I will change it.

>
>> +/* Print HECC registers */
>> +static void hecc_print_regs(struct seq_file *s)
>> +{
>
>I discovered lot's of debug code (>20%).
>
>Is this really needed?

Not really. I started with lots of debug code as I thought I would really need it and it was indeed helpful initially - I intended on removing it later but I thought keeping more debug code may not be a bad idea though I don't have any strong preference on this. Occasionally it is helpful to look at all registers and hence I coded it under CONFIG_DEBUG_FS.

>
>
>
>> +static char *hecc_debug_can_state[] = {
>> +	"CAN_STATE_ERROR_ACTIVE",
>> +	"CAN_STATE_ERROR_WARNING",
>> +	"CAN_STATE_ERROR_PASSIVE",
>> +	"CAN_STATE_BUS_OFF",
>> +	"CAN_STATE_STOPPED",
>> +	"CAN_STATE_SLEEPING",
>> +	"CAN_STATE_MAX"
>> +};
>
>Hm - defining this in a driver looks like a bad idea.
>
>Maybe we could move this to the CAN driver interface depending on
>
>CONFIG_CAN_DEBUG_DEVICES
>
>?!?

Agreed - this was again just for my debug. It would help as you mentioned for debug and can potentially go under can netlink.h.

>> +
>> +/** Toggle HECC Self-Test i.e loopback bit
>> + * INFO: Reading this debug variable toggles the loopback status on the
>device.
>> + * This is done to simplify the debug function to set looback
>> + */
>> +static int hecc_debug_loopback(struct seq_file *s)
>> +{
>> +	static int toggle;
>> +
>> +	/* Put module in self test mode i.e. loopback */
>> +	if (toggle) {
>> +		seq_printf(s, "In Self Test Mode (loopback)\n");
>> +		hecc_set_bit(debug_priv, HECC_CANMC, HECC_CANMC_STM);
>> +		toggle = 0;
>> +	} else {
>> +		seq_printf(s, "Out of Self Test Mode (NO loopback)\n");
>> +		hecc_clear_bit(debug_priv, HECC_CANMC, HECC_CANMC_STM);
>> +		toggle = 1;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>
>Ugh!
>
>No. This should definitely be done by netlink.

yes completely agreed - for some reason I did not get to compile iproute2 utils and hence used this for quick/easy debug of my driver. I will remove it.

>
>I did not take a closer look into the device access and error handling
>right
>now. So this was just my first impression :-)
>

Thanks for the quick feedback. Appreciate it. I will wait for more from you and others too.

>Thanks,
>Oliver

