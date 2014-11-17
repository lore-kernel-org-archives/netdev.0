From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v4 3/8] net: can: c_can: Add RAMINIT register information
 to driver data
Date: Mon, 17 Nov 2014 13:17:56 +0200
Message-ID: <5469D964.8020804@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-4-git-send-email-rogerq@ti.com> <54664212.8080206@pengutronix.de>
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
In-Reply-To: <54664212.8080206@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2014 07:55 PM, Marc Kleine-Budde wrote:
> On 11/07/2014 03:49 PM, Roger Quadros wrote:
>> Some platforms (e.g. TI) need special RAMINIT register handling.
>> Provide a way to store RAMINIT register description in driver data.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>  drivers/net/can/c_can/c_can.h          | 6 ++++++
>>  drivers/net/can/c_can/c_can_platform.c | 1 +
>>  2 files changed, 7 insertions(+)
>>
>> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
>> index 26c975d..3c305a1 100644
>> --- a/drivers/net/can/c_can/c_can.h
>> +++ b/drivers/net/can/c_can/c_can.h
>> @@ -171,6 +171,12 @@ enum c_can_dev_id {
>>  
>>  struct c_can_driver_data {
>>  	enum c_can_dev_id id;
>> +
>> +	/* RAMINIT register description. Optional. */
>> +	u8 num_can;		/* Number of CAN instances on the SoC */
>> +	u8 *raminit_start_bits;	/* Array of START bit positions */
>> +	u8 *raminit_done_bits;	/* Array of DONE bit positions */
> 
> What do you think about making this a struct:
> 
> +struct raminit_bits {
> +       u8 start;
> +       u8 done;
> +};
> 
>  struct c_can_driver_data {
>         enum c_can_dev_id id;
> +
> +       /* RAMINIT register description. Optional. */
> +       const struct raminit_bits *raminit_bits; /* Array of START/DONE bit positions */
> +       u8 raminit_num;         /* Number of CAN instances on the SoC */
> +       bool raminit_pulse;     /* If set, sets and clears START bit (pulse) */
>  };
> 
> The driver data looks like this:
> 
> +static const struct raminit_bits dra7_raminit_bits[] = {
> +       [0] = { .start = 3, .done = 1, },
> +       [1] = { .start = 5, .done = 2, },
> +};
> +
> +static const struct c_can_driver_data dra7_dcan_drvdata = {
> +       .id = BOSCH_D_CAN,
> +       .raminit_num = ARRAY_SIZE(dra7_raminit_bits),
> +       .raminit_bits = dra7_raminit_bits,
> +       .raminit_pulse = true,
> +};
> 
> I'll send an updated series.

Looks better. Thanks.

cheers,
-roger
