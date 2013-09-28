From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Sat, 28 Sep 2013 04:52:59 +0400
Message-ID: <5246286B.6020905@cogentembedded.com>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com> <20130927174518.2ee83214@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20130927174518.2ee83214@nehalam.linuxnetplumber.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/28/2013 04:45 AM, Stephen Hemminger wrote:

>> +	stats->rx_bytes += cf->can_dlc;
>> +}
>> +
>> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
>> +{
>> +	struct net_device *ndev = (struct net_device *)dev_id;
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +	u8 isr;
>> +
>> +	isr = rcar_can_readb(priv, RCAR_CAN_ISR);
>> +	if (isr & ISR_ERSF)
>> +		rcar_can_error(ndev);

> IRQ handler should return IRQ_NONE if not for this device.
> Most devices this is true if isr is 0.

    Hm, totally overlooked that... :-/

> Also should check for hot-plug case where device interrupt occurs
> but see's all-ones on the bus.

    Hotplug is not possible with this SoC device.

WBR, Sergei

