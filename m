From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v4 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Mon, 10 Nov 2014 11:00:31 +0200
Message-ID: <54607EAF.40602@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <545CDD30.2070508@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <545CDD30.2070508@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/07/2014 04:54 PM, Marc Kleine-Budde wrote:
> On 11/07/2014 03:49 PM, Roger Quadros wrote:
>> DRA7 CAN IP suffers from a problem which causes it to be prevented
>> from fully turning OFF (i.e. stuck in transition) if the module was
>> disabled while there was traffic on the CAN_RX line.
>>
>> To work around this issue we select the SLEEP pin state by default
>> on probe and use the DEFAULT pin state on CAN up and back to the
>> SLEEP pin state on CAN down.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>  drivers/net/can/c_can/c_can.c          | 20 ++++++++++++++++++++
>>  drivers/net/can/c_can/c_can.h          |  1 +
>>  drivers/net/can/c_can/c_can_platform.c | 20 ++++++++++++++++++++
>>  3 files changed, 41 insertions(+)
>>
>> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
>> index 8e78bb4..4dfc3ce 100644
>> --- a/drivers/net/can/c_can/c_can.c
>> +++ b/drivers/net/can/c_can/c_can.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/list.h>
>>  #include <linux/io.h>
>>  #include <linux/pm_runtime.h>
>> +#include <linux/pinctrl/consumer.h>
>>  
>>  #include <linux/can.h>
>>  #include <linux/can/dev.h>
>> @@ -603,6 +604,15 @@ static int c_can_start(struct net_device *dev)
>>  
>>  	priv->can.state = CAN_STATE_ERROR_ACTIVE;
>>  
>> +	/* activate pins */
>> +	if (!IS_ERR(priv->pinctrl)) {
>> +		struct pinctrl_state *s;
>> +
>> +		s = pinctrl_lookup_state(priv->pinctrl, PINCTRL_STATE_DEFAULT);
>> +		if (!IS_ERR(s))
>> +			pinctrl_select_state(priv->pinctrl, s);
>> +	}
> 
> Please put this common code into a seperate function.

Oops, forgot this one in a hurry.

cheers,
-roger
