From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 09:42:34 +0000
Message-ID: <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
 <1401415552-2263-5-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0204.outbound.protection.outlook.com ([207.46.163.204]:33485
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755160AbaE3Jmz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 05:42:55 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM> Data: Friday, May 30, 2014 5:11 PM
>To: Duan Fugang-B38611; Li Frank-B20596; davem@davemloft.net
>Cc: ezequiel.garcia@free-electrons.com; netdev@vger.kernel.org;
>shawn.guo@linaro.org; bhutchings@solarflare.com;
>stephen@networkplumber.org
>Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry
>number
>
>From: Fugang Duan
>> In order to support SG, software TSO, let's increase BD entry number.
>
>Software TSO shouldn't significantly increase the number of descriptors
>required.
>I'd guess it makes a lot of packets have 2 fragments.
>
>...
>> -#define FEC_ENET_RX_PAGES	8
>> +#define FEC_ENET_RX_PAGES	256
>
>Supporting TSO shouldn't need more RX descriptors.
>While 16 descriptors isn't that many, 512 is a lot.
>If PAGE_SIZE is greater than 4k it is a huge amount of memory.
>
Yes, 16 descriptors is little, increase BD entry size can improve the performance.
And I want to add the later patch to support interrupt coalescing, which need more BD descriptors.

>>  #define FEC_ENET_RX_FRSIZE	2048
>>  #define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
>>  #define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
>>  #define FEC_ENET_TX_FRSIZE	2048
>>  #define FEC_ENET_TX_FRPPG	(PAGE_SIZE / FEC_ENET_TX_FRSIZE)
>> -#define TX_RING_SIZE		16	/* Must be power of two */
>> -#define TX_RING_MOD_MASK	15	/*   for this to work */
>> +#define TX_RING_SIZE		512	/* Must be power of two */
>> +#define TX_RING_MOD_MASK	511	/*   for this to work */
>
>Does the driver support BQL (or similar) in order to limit the amount of
>queued tx traffic?
>Otherwise you've significantly increased the latency for connections other
>than one doing bulk tx.
>
>	David
>
The driver still don't support BQL.
I will add the feature to support FEC. Thanks for your advise.

Thanks,
Andy
