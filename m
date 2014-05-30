From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 09:10:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
 <1401415552-2263-5-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: 'Fugang Duan' <b38611@freescale.com>,
	"b20596@freescale.com" <b20596@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55074 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932551AbaE3JMI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 05:12:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16489-09 for <netdev@vger.kernel.org>;
 Fri, 30 May 2014 10:11:57 +0100 (BST)
In-Reply-To: <1401415552-2263-5-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan
> In order to support SG, software TSO, let's increase BD entry number.

Software TSO shouldn't significantly increase the number of
descriptors required.
I'd guess it makes a lot of packets have 2 fragments.

...
> -#define FEC_ENET_RX_PAGES	8
> +#define FEC_ENET_RX_PAGES	256

Supporting TSO shouldn't need more RX descriptors.
While 16 descriptors isn't that many, 512 is a lot.
If PAGE_SIZE is greater than 4k it is a huge amount of memory.

>  #define FEC_ENET_RX_FRSIZE	2048
>  #define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
>  #define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
>  #define FEC_ENET_TX_FRSIZE	2048
>  #define FEC_ENET_TX_FRPPG	(PAGE_SIZE / FEC_ENET_TX_FRSIZE)
> -#define TX_RING_SIZE		16	/* Must be power of two */
> -#define TX_RING_MOD_MASK	15	/*   for this to work */
> +#define TX_RING_SIZE		512	/* Must be power of two */
> +#define TX_RING_MOD_MASK	511	/*   for this to work */

Does the driver support BQL (or similar) in order to limit
the amount of queued tx traffic?
Otherwise you've significantly increased the latency for
connections other than one doing bulk tx.

	David
