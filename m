From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 13/16] net: fec: print more debug info in
 fec_timeout
Date: Fri, 4 Mar 2016 09:05:12 -0700
Message-ID: <56D9B238.2040400@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-14-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18552AB3E4128E412273B439FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36504 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759800AbcCDQFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:05:14 -0500
Received: by mail-pa0-f52.google.com with SMTP id fi3so35069582pac.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 08:05:13 -0800 (PST)
In-Reply-To: <VI1PR0401MB18552AB3E4128E412273B439FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/2016 3:06 AM, Fugang Duan wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
>> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
>> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
>> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
>> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
>> johannes@sipsolutions.net; stillcompiling@gmail.com;
>> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
>> <troy.kisky@boundarydevices.com>
>> Subject: [PATCH net-next V2 13/16] net: fec: print more debug info in
>> fec_timeout
>>
>> Print the current interrupt flags and mask and the interrupt state during the last
>> interrupt in fec_timeout.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>> ---
>>  drivers/net/ethernet/freescale/fec.h      | 1 +
>>  drivers/net/ethernet/freescale/fec_main.c | 4 ++++
>>  2 files changed, 5 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.h
>> b/drivers/net/ethernet/freescale/fec.h
>> index 001200b..615cca1 100644
>> --- a/drivers/net/ethernet/freescale/fec.h
>> +++ b/drivers/net/ethernet/freescale/fec.h
>> @@ -506,6 +506,7 @@ struct fec_enet_private {
>>  	unsigned int total_tx_ring_size;
>>  	unsigned int total_rx_ring_size;
>>  	uint	events;
>> +	uint	last_ievents;
>>
>>  	struct	platform_device *pdev;
>>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index afd4060..9a3136b 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -1107,6 +1107,9 @@ fec_timeout(struct net_device *ndev)
>>  	int i;
>>  	uint events = 0;
>>
>> +	pr_err("%s: last=%x %x, mask %x\n", __func__, fep->last_ievents,
>> +	       readl(fep->hwp + FEC_IEVENT), readl(fep->hwp + FEC_IMASK));
>> +
> pr_err() -> netdev_err()
> 


Sounds good
