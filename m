From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next 08/40] net: fec: move cbd_bufaddr assignment
 closer to the mapping function
Date: Fri, 29 Jan 2016 10:49:35 -0700
Message-ID: <56ABA62F.3050003@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
 <1454016364-30985-9-git-send-email-troy.kisky@boundarydevices.com>
 <1725152.bhtFKTSjnb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, andrew@lunn.ch,
	linux@arm.linux.org.uk, laci@boundarydevices.com,
	l.stach@pengutronix.de, shawnguo@kernel.org, tremyfr@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36818 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbcA2Rtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 12:49:35 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so44634356pab.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 09:49:35 -0800 (PST)
In-Reply-To: <1725152.bhtFKTSjnb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/28/2016 3:02 PM, Arnd Bergmann wrote:
> On Thursday 28 January 2016 14:25:32 Troy Kisky wrote:
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>> ---
>>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> [note: missing changelog?]
> 
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>> index b87f80d..15a93f90 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -476,6 +476,8 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
>>  				estatus |= BD_ENET_TX_TS;
>>  		}
>>  	}
>> +	bdp->cbd_bufaddr = addr;
>> +	bdp->cbd_datlen = buflen;
>>  
>>  	if (fep->bufdesc_ex) {
>>  
>> @@ -499,8 +501,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
>>  	/* Save skb pointer */
>>  	txq->tx_skbuff[index] = skb;
>>  
>> -	bdp->cbd_datlen = buflen;
>> -	bdp->cbd_bufaddr = addr;
>>  	/* Make sure the updates to rest of the descriptor are performed before
>>  	 * transferring ownership.
>>  	 */
>>
> 
> This patch and others in the series conflicts with the bugfix "net: fec: make
> driver endian-safe" that Johannes sent this week. Can you include his fix
> in your series and ensure that all descriptor accesses are done in
> an endian-safe way?
> 
> 	Arnd

Sure, I'll rebase and send the first few when net-next is updated.

Thanks
Troy
