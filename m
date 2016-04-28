From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Thu, 28 Apr 2016 08:27:35 +0200
Message-ID: <5721AD57.8060105@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56FD8DC8.4050205@pengutronix.de>
 <SG2PR06MB10389E1E68089FF900746B44C39A0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <KL1PR06MB10312B266592335D965823AFC3960@KL1PR06MB1031.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <KL1PR06MB10312B266592335D965823AFC3960@KL1PR06MB1031.apcprd06.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ramesh,

please send out a new v3 patchset to trigger the process again :-)

Best regards,
Oliver

On 04/13/2016 08:25 AM, Ramesh Shanmugasundaram wrote:
> HI Marc,
>
> Gentle reminder!
> Are you happy with the open comment's disposition? I can send a next version of patch if we have a closure on current set of comments.
>
> Thanks,
> Ramesh
>
>> -----Original Message-----
>> From: Ramesh Shanmugasundaram
>> Sent: 01 April 2016 13:49
>> To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>;
>> wg@grandegger.com; robh+dt@kernel.org; pawel.moll@arm.com;
>> mark.rutland@arm.com; ijc+devicetree@hellion.org.uk; galak@codeaurora.org;
>> corbet@lwn.net
>> Cc: linux-renesas-soc@vger.kernel.org; devicetree@vger.kernel.org; linux-
>> can@vger.kernel.org; netdev@vger.kernel.org; linux-doc@vger.kernel.org;
>> geert+renesas@glider.be; Chris Paterson <Chris.Paterson2@renesas.com>
>> Subject: RE: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
>>
>> Hi Marc,
>>
>> Thanks for your time & review comments.
>>
>>> -----Original Message-----
>> (...)
>>>> +#define RCANFD_NAPI_WEIGHT		8	/* Rx poll quota */
>>>> +
>>>> +#define RCANFD_NUM_CHANNELS		2
>>>> +#define RCANFD_CHANNELS_MASK		0x3	/* Two channels max */
>>>
>>> (BIT(RCANFD_NUM_CHANNELS) - 1
>>
>> OK
>>
>>>
>>>> +
>>>> +/* Rx FIFO is a global resource of the controller. There are 8 such
>>> FIFOs
>>>> + * available. Each channel gets a dedicated Rx FIFO (i.e.) the
>>>> + channel
>> (...)
>>>> +#define RCANFD_CMFIFO_CFDLC(x)		(((x) & 0xf) << 28)
>>>> +#define RCANFD_CMFIFO_CFPTR(x)		(((x) & 0xfff) << 16)
>>>> +#define RCANFD_CMFIFO_CFTS(x)		(((x) & 0xff) << 0)
>>>> +
>>>> +/* Global Test Config register */
>>>> +#define RCANFD_GTSTCFG_C0CBCE		BIT(0)
>>>> +#define RCANFD_GTSTCFG_C1CBCE		BIT(1)
>>>> +
>>>> +#define RCANFD_GTSTCTR_ICBCTME		BIT(0)
>>>> +
>>>> +/* AFL Rx rules registers */
>>>> +#define RCANFD_AFLCFG_SETRNC0(x)	(((x) & 0xff) << 24)
>>>> +#define RCANFD_AFLCFG_SETRNC1(x)	(((x) & 0xff) << 16)
>>>
>>> What about something like:
>>>
>>> #define RCANFD_AFLCFG_SETRNC(n, x)	(((x) & 0xff) << (24 - n * 8))
>>>
>>> This will save some if()s in the code
>>
>> Nice :-). Will update.
>>
>>>
>>>> +#define RCANFD_AFLCFG_GETRNC0(x)	(((x) >> 24) & 0xff)
>>>> +#define RCANFD_AFLCFG_GETRNC1(x)	(((x) >> 16) & 0xff)
>>>> +
>>>> +#define RCANFD_AFL_PAGENUM(entry)	((entry) / 16)
>> (...)
>>>> +#define rcar_canfd_read(priv, offset)			\
>>>> +	readl(priv->base + (offset))
>>>> +#define rcar_canfd_write(priv, offset, val)		\
>>>> +	writel(val, priv->base + (offset))
>>>> +#define rcar_canfd_set_bit(priv, reg, val)		\
>>>> +	rcar_canfd_update(val, val, priv->base + (reg))
>>>> +#define rcar_canfd_clear_bit(priv, reg, val)		\
>>>> +	rcar_canfd_update(val, 0, priv->base + (reg))
>>>> +#define rcar_canfd_update_bit(priv, reg, mask, val)	\
>>>> +	rcar_canfd_update(mask, val, priv->base + (reg))
>>>
>>> please use static inline functions instead of defines.
>>
>> OK.
>>
>>>
>>>> +
>>>> +static void rcar_canfd_get_data(struct canfd_frame *cf,
>>>> +				struct rcar_canfd_channel *priv, u32 off)
>>>
>>> Please use "struct rcar_canfd_channel *priv" as first argument, struct
>>> canfd_frame *cf as second. Remove off, as the offset is already
>>> defined by the channel.
>>
>> I'll re-order priv, cf as you mentioned. I'll leave "off" arg as it is
>> because it is based on FIFO number of channel + mode (CAN only or CANFD
>> only). Otherwise, I will have to add another check inside this function
>> for mode.
>>
>>>> +{
>>>> +	u32 i, lwords;
>>>> +
>>>> +	lwords = cf->len / sizeof(u32);
>>>> +	if (cf->len % sizeof(u32))
>>>> +		lwords++;
>>>
>>> Use DIV_ROUND_UP() instead of open coding it.
>>
>> Agreed. Thanks.
>>
>>>
>>>> +	for (i = 0; i < lwords; i++)
>>>> +		*((u32 *)cf->data + i) =
>>>> +			rcar_canfd_read(priv, off + (i * sizeof(u32))); }
>>>> +
>>>> +static void rcar_canfd_put_data(struct canfd_frame *cf,
>>>> +				struct rcar_canfd_channel *priv, u32 off)
>>>
>>> same here
>>
>> Yes (same as _get_data)
>>
>>>
>>>> +{
>>>> +	u32 i, j, lwords, leftover;
>>>> +	u32 data = 0;
>>>> +
>>>> +	lwords = cf->len / sizeof(u32);
>>>> +	leftover = cf->len % sizeof(u32);
>>>> +	for (i = 0; i < lwords; i++)
>>>> +		rcar_canfd_write(priv, off + (i * sizeof(u32)),
>>>> +				 *((u32 *)cf->data + i));
>>>
>>> Here you don't convert the endianess...
>>
>> Yes
>>
>>>> +
>>>> +	if (leftover) {
>>>> +		u8 *p = (u8 *)((u32 *)cf->data + i);
>>>> +
>>>> +		for (j = 0; j < leftover; j++)
>>>> +			data |= p[j] << (j * 8);
>>>
>>> ...here you do an implicit endianess conversion. "data" is little
>>> endian, while p[j] is big endian.
>>
>> Not sure I got the question correctly.
>> Controller expectation of data bytes in 32bit register is bits[7:0] =
>> byte0, bits[15:8] = byte1 and so on - little endian.
>> For e.g. if cf->data points to byte stream H'112233445566 (cf->data[0] =
>> 0x11), first rcar_canfd_write will write 0x44332211 value to register. Yes
>> the host cpu is assumed little endian. In leftover case, data will be
>> 0x00006655 - again little endian.
>> I think I should remove this leftover logic and just mask the unused bits
>> to zero as cf->data is pre-allocated for max length anyway.
>>
>> p[j] is a byte?? Am I missing something?
>>
>>>
>>>> +		rcar_canfd_write(priv, off + (i * sizeof(u32)), data);
>>>> +	}
>>>
>>> Have you tested to send CAN frames with len != n*4 against a different
>>> controller?
>>
>> Yes, with Vector VN1630A.
>>
>>>> +}
>>>> +
>>>> +static void rcar_canfd_tx_failure_cleanup(struct net_device *ndev)
>>>> +{
>>>> +	u32 i;
>>>> +
>>>> +	for (i = 0; i < RCANFD_FIFO_DEPTH; i++)
>>>> +		can_free_echo_skb(ndev, i);
>>>> +}
>>>> +
>> (...)
>>>> +static void rcar_canfd_tx_done(struct net_device *ndev) {
>>>> +	struct rcar_canfd_channel *priv = netdev_priv(ndev);
>>>> +	struct net_device_stats *stats = &ndev->stats;
>>>> +	u32 sts;
>>>> +	unsigned long flags;
>>>> +	u32 ch = priv->channel;
>>>> +
>>>> +	do {
>>>
>>> You should iterare over all pending CAN frames:
>>>
>>>> 	for (/* nix */; (priv->tx_head - priv->tx_tail) > 0; priv-
>>>> tx_tail++) {
>>>
>>
>> Yes, current code does iterate over pending tx'ed frames. If we use this
>> for loop semantics, we may have to protect the whole loop with no real
>> benefit.
>>
>>>
>>>> +		u8 unsent, sent;
>>>> +
>>>> +		sent = priv->tx_tail % RCANFD_FIFO_DEPTH;
>>>
>>> and check here, if that packet has really been tramsitted. Exit the
>>> loop otherweise.
>>
>> We are here because of tx_done and hence no need to check tx done again
>> for the first iteration. Hence the do-while loop. Checks further down
>> takes care of the need for more iterations/pending tx'ed frames.
>>
>>>
>>>> +		stats->tx_packets++;
>>>> +		stats->tx_bytes += priv->tx_len[sent];
>>>> +		priv->tx_len[sent] = 0;
>>>> +		can_get_echo_skb(ndev, sent);
>>>> +
>>>> +		spin_lock_irqsave(&priv->tx_lock, flags);
>>>
>>> What does the tx_lock protect? The tx path is per channel, isn't it?
>>
>> You are right - tx path is per channel. In tx path, head & tail are also
>> used to determine when to stop/wakeup netif queue. They are incremented &
>> compared in different contexts to make this decision. Per channel tx_lock
>> protects this critical section.
>>
>>>
>>>> +		priv->tx_tail++;
>>>> +		sts = rcar_canfd_read(priv,
>>>> +				      RCANFD_CFSTS(ch, RCANFD_CFFIFO_IDX));
>>>> +		unsent = RCANFD_CMFIFO_CFMC(sts);
>>>> +
>>>> +		/* Wake producer only when there is room */
>>>> +		if (unsent != RCANFD_FIFO_DEPTH)
>>>> +			netif_wake_queue(ndev);
>>>
>>> Move the netif_wake_queue() out of the loop.
>>
>> With the tx logic mentioned above, I think keeping it in the loop seems
>> better. For e.g. say cpu1 pumps 8 frames from an app loop and cpu0 handles
>> tx_done interrupt handling: cpu1 would have stopped the queue because FIFO
>> is full -> cpu0 gets tx_done interrupt and by the time it checks "unsent"
>> there could be one or more frames transmitted by device (i.e.) there would
>> be more space in fifo. It is better to wakeup the netif queue then and
>> there so that app running on cpu1 can pump more. If we move it out of the
>> loop we wake up the queue only in the end. Have I missed anything?
>>
>>>
>>>> +
>>>> +		if (priv->tx_head - priv->tx_tail <= unsent) {
>>>> +			spin_unlock_irqrestore(&priv->tx_lock, flags);
>>>> +			break;
>>>> +		}
>>>> +		spin_unlock_irqrestore(&priv->tx_lock, flags);
>>>> +
>>>> +	} while (1);
>>>> +
>>>> +	/* Clear interrupt */
>>>> +	rcar_canfd_write(priv, RCANFD_CFSTS(ch, RCANFD_CFFIFO_IDX),
>>>> +			 sts & ~RCANFD_CMFIFO_CFTXIF);
>>>> +	can_led_event(ndev, CAN_LED_EVENT_TX); }
>>>> +
>>>> +	if (cf->can_id & CAN_RTR_FLAG)
>>>> +		id |= RCANFD_CMFIFO_CFRTR;
>>>> +
>>>> +	rcar_canfd_write(priv, RCANFD_F_CFID(ch, RCANFD_CFFIFO_IDX),
>>>> +			 id);
>>>> +	ptr = RCANFD_CMFIFO_CFDLC(can_len2dlc(cf->len));
>>>
>>> ptr usually means pointer, better call it dlc.
>>
>> I used the register name "ptr". OK, will change it do dlc.
>>
>>>
>>>> +	rcar_canfd_write(priv, RCANFD_F_CFPTR(ch, RCANFD_CFFIFO_IDX),
>>>> +			 ptr);
>>>> +
>> (...)
>>>> +	can_put_echo_skb(skb, ndev, priv->tx_head % RCANFD_FIFO_DEPTH);
>>>> +
>>>> +	spin_lock_irqsave(&priv->tx_lock, flags);
>>>> +	priv->tx_head++;
>>>> +
>>>> +	/* Start Tx: Write 0xff to CFPC to increment the CPU-side
>>>> +	 * pointer for the Common FIFO
>>>> +	 */
>>>> +	rcar_canfd_write(priv, RCANFD_CFPCTR(ch, RCANFD_CFFIFO_IDX),
>>>> +0xff);
>>>> +
>>>> +	/* Stop the queue if we've filled all FIFO entries */
>>>> +	if (priv->tx_head - priv->tx_tail >= RCANFD_FIFO_DEPTH)
>>>> +		netif_stop_queue(ndev);
>>>
>>> Please move the check of stop_queue, before starting the send.
>>
>> OK.
>>
>>>
>>>> +
>>>> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
>>>> +	return NETDEV_TX_OK;
>>>> +}
>>>> +
>> (...)
>>>> +{
>>>> +	struct rcar_canfd_channel *priv =
>>>> +		container_of(napi, struct rcar_canfd_channel, napi);
>>>> +	int num_pkts;
>>>> +	u32 sts;
>>>> +	u32 ch = priv->channel;
>>>> +	u32 ridx = ch + RCANFD_RFFIFO_IDX;
>>>> +
>>>> +	for (num_pkts = 0; num_pkts < quota; num_pkts++) {
>>>> +		sts = rcar_canfd_read(priv, RCANFD_RFSTS(ridx));
>>>> +		/* Clear interrupt bit */
>>>> +		if (sts & RCANFD_RFFIFO_RFIF)
>>>> +			rcar_canfd_write(priv, RCANFD_RFSTS(ridx),
>>>> +					 sts & ~RCANFD_RFFIFO_RFIF);
>>>> +
>>>> +		/* Check FIFO empty condition */
>>>> +		if (sts & RCANFD_RFFIFO_RFEMP)
>>>> +			break;
>>>> +
>>>> +		rcar_canfd_rx_pkt(priv);
>>>
>>> This sequence looks strange. You first conditionally ack the interrupt
>>> then you check for empty fifo, then read the CAN frame. I would assume
>>> that you first check if there's a CAN frame, read it and then clear
>>> the interrupt.
>>
>> Yes, I shall re-arrange the sequence as you mentioned.
>>
>>>
>>>> +	}
>>>> +
>>>> +	/* All packets processed */
>>>> +	if (num_pkts < quota) {
>>>> +		napi_complete(napi);
>>>> +		/* Enable Rx FIFO interrupts */
>>>> +		rcar_canfd_set_bit(priv, RCANFD_RFCC(ridx),
>>> RCANFD_RFFIFO_RFIE);
>> (...)
>>>> +	for_each_set_bit(ch, &gpriv->channels_mask, RCANFD_NUM_CHANNELS) {
>>>> +		err = rcar_canfd_channel_probe(gpriv, ch);
>>>> +		if (err)
>>>> +			goto fail_channel;
>>>> +	}
>>>
>>> Should the CAN IP core be clocked the whole time? What about shuting
>>> down the clock and enabling it on ifup?
>>
>> The fCAN clock is enabled only on ifup of one of the channels. However,
>> the peripheral clock is enabled during probe to bring the controller to
>> Global Operational mode. This clock cannot be turned off with the register
>> values & mode retained.
>>
>>>> +
>>>> +	platform_set_drvdata(pdev, gpriv);
>>>> +	dev_info(&pdev->dev, "global operational state (clk %d)\n",
>>>> +		 gpriv->clock_select);
>> (...)
>>>> +	rcar_canfd_reset_controller(gpriv);
>>>> +	rcar_canfd_disable_global_interrupts(gpriv);
>>>> +
>>>> +	for_each_set_bit(ch, &gpriv->channels_mask, RCANFD_NUM_CHANNELS) {
>>>> +		priv = gpriv->ch[ch];
>>>> +		if (priv) {
>>>
>>> This should always be true.
>>
>> I agree. I thought I cleaned this up but it's in my local commits :-(
>>
>>>
>>>> +			rcar_canfd_disable_channel_interrupts(priv);
>>>> +			unregister_candev(priv->ndev);
>>>> +			netif_napi_del(&priv->napi);
>>>> +			free_candev(priv->ndev);
>>>
>>> Please make use of rcar_canfd_channel_remove(), as you already have
>>> the function.
>>
>> Yes.
>>
>> Thanks,
>> Ramesh
