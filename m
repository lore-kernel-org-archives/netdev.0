From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V2 2/4] net: can: ifi: Fix TX DLC configuration
Date: Wed, 02 Mar 2016 21:14:13 +0100
Message-ID: <56D74995.8010907@denx.de>
References: <1456915359-6775-1-git-send-email-marex@denx.de> <1456915359-6775-3-git-send-email-marex@denx.de> <56D7351B.1060403@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56D7351B.1060403@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/2016 07:46 PM, Oliver Hartkopp wrote:
> Hi Marek,

Hi!

> sorry for picking this patch up again.

nothing to be sorry about, thanks for the input :)

> After looking around in the original source I have one more comment:
> 
> On 03/02/2016 11:42 AM, Marek Vasut wrote:
> 
>> -	if (priv->can.ctrlmode & (CAN_CTRLMODE_FD | CAN_CTRLMODE_FD_NON_ISO)) {
>> -		if (can_is_canfd_skb(skb)) {
>> -			txdlc |= IFI_CANFD_TXFIFO_DLC_EDL;
>> -			if (cf->flags & CANFD_BRS)
>> -				txdlc |= IFI_CANFD_TXFIFO_DLC_BRS;
>> -		}
>> +	txdlc |= can_len2dlc(cf->len);
> 
> At the top of the function you defined
> 
> 	u32 txst, txid;
> 	u32 txdlc = 0;
> 
> and here you use 'txdlc |= ...'.
> 
> That's weird style IMO.
> 
> Please change it to
> 
> 	u32 txst, txid, txdlc;
> 
> and
> 
> 	txdlc = can_len2dlc(cf->len);

I'll send a V3 shortly.

btw. I forgot to add V2 to the 3/4 and 4/4 patches, sigh.


-- 
Best regards,
Marek Vasut
