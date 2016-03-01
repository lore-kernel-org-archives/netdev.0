From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 03/16] net: fec: pass txq to fec_enet_tx_queue
 instead of queue_id
Date: Tue, 1 Mar 2016 14:51:26 -0700
Message-ID: <56D60EDE.7090100@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-4-git-send-email-troy.kisky@boundarydevices.com>
 <CAHrpEqSyuToC6QFEZygO0YyA=gV2cZEtkpRJMeZFOjhgTLdexQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Andrew Lunn <andrew@lunn.ch>, tremyfr@gmail.com,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, laci@boundarydevices.com,
	Shawn Guo <shawnguo@kernel.org>, johannes@sipsolutions.net,
	Joshua Clayton <stillcompiling@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Arnd Bergmann <arnd@arndb.de>
To: Zhi Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32865 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbcCAVv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 16:51:27 -0500
Received: by mail-pa0-f52.google.com with SMTP id fl4so119331147pad.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 13:51:27 -0800 (PST)
In-Reply-To: <CAHrpEqSyuToC6QFEZygO0YyA=gV2cZEtkpRJMeZFOjhgTLdexQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2016 2:06 PM, Zhi Li wrote:
> On Wed, Feb 24, 2016 at 6:36 PM, Troy Kisky
> <troy.kisky@boundarydevices.com> wrote:
>> queue_id is the qid member of struct bufdesc_prop.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>> ---
>>  drivers/net/ethernet/freescale/fec_main.c | 17 ++++++-----------
>>  1 file changed, 6 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>> index 9619b9e..c517194 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -1156,25 +1156,18 @@ fec_enet_hwtstamp(struct fec_enet_private *fep, unsigned ts,
>>         hwtstamps->hwtstamp = ns_to_ktime(ns);
>>  }
>>
>> -static void
>> -fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
>> +static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
>> +                   struct fec_enet_priv_tx_q *txq)
> 
> you can get fep from ndev.
> 

True, but fec_txq/fec_rxq is called in a loop. Why not pass it, rather than
look it up again?
