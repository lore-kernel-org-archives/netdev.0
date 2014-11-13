From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V4 2/3] can: m_can: update to support CAN FD features
Date: Thu, 13 Nov 2014 17:56:55 +0100
Message-ID: <5464E2D7.7010906@hartkopp.net>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com> <1415349914-9145-2-git-send-email-b29396@freescale.com> <54648382.9080105@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54648382.9080105@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 11:10 AM, Marc Kleine-Budde wrote:
> On 11/07/2014 09:45 AM, Dong Aisheng wrote:

>>  
>> -	if (id & RX_BUF_RTR) {
>> +	if (id & RX_BUF_ESI) {
>> +		cf->flags |= CANFD_ESI;
>> +		netdev_dbg(dev, "ESI Error\n");
>> +	}
>> +
>> +	if (!(dlc & RX_BUF_EDL) && (id & RX_BUF_RTR)) {
>>  		cf->can_id |= CAN_RTR_FLAG;
> 
> I just noticed, that you don't set the cf->dlc (or cf->len) in the RTR
> case. Please create a separate patch that fixes this problem.
> 
>>  	} else {
>>  		id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
>> -		cf->can_dlc = get_can_dlc((id >> 16) & 0x0F);
>> -		*(u32 *)(cf->data + 0) = m_can_fifo_read(priv, fgi,
>> -							 M_CAN_FIFO_DATA(0));
>> -		*(u32 *)(cf->data + 4) = m_can_fifo_read(priv, fgi,
>> -							 M_CAN_FIFO_DATA(1));
>> +		if (dlc & RX_BUF_EDL)
>> +			cf->len = can_dlc2len((id >> 16) & 0x0F);
>> +		else
>> +			cf->len = get_can_dlc((id >> 16) & 0x0F);
>> +

Grr. I missed that one too :-(

Thanks for catching it.

As you committed patch 1 & 3 you expect a new single patch containing the
(fixed) content of this patch 2, right?

Regards,
Oliver

