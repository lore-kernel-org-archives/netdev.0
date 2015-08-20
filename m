From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] qeth: Convert use of __constant_htons to
 htons
Date: Thu, 20 Aug 2015 10:46:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB804CD@AcuExch.aculab.com>
References: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
 <1439972454-64347-3-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"ursula.braun@de.ibm.com" <ursula.braun@de.ibm.com>,
	Vaishali Thakkar <vthakkar1994@gmail.com>
To: 'Ursula Braun' <ubraun@linux.vnet.ibm.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:64870 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbbHTKtk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 06:49:40 -0400
In-Reply-To: <1439972454-64347-3-git-send-email-ubraun@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun
> Sent: 19 August 2015 09:21
> In little endian cases, the macro htons unfolds to __swab16 which
> provides special case for constants. In big endian cases,
> __constant_htons and htons expand directly to the same expression.
> So, replace __constant_htons with htons with the goal of getting
> rid of the definition of __constant_htons completely.
...
> diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
> index 70eb2f6..ecfe622 100644
> --- a/drivers/s390/net/qeth_l3_main.c
> +++ b/drivers/s390/net/qeth_l3_main.c
> @@ -1887,13 +1887,13 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
>  		case QETH_CAST_MULTICAST:
>  			switch (prot) {
>  #ifdef CONFIG_QETH_IPV6
> -			case __constant_htons(ETH_P_IPV6):
> +			case htons(ETH_P_IPV6):

I didn't think htons() was 'constant enough' to be used as a case label.

Using byteswapped constants in a case statement can change it from being
implemented as a jump table to a branch tree.
This might be more expensive than byteswapping the value (even on systems
that don't have cheap byteswap instructions).

	David
