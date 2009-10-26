From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH net-next] bnx2x: Do Tx handling in a separate
 tasklet.
Date: Mon, 26 Oct 2009 07:42:27 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB2CFF1C42@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1256473182.11634.4.camel@lb-tlvb-vladz.il.broadcom.com>
 <20091025.142059.175260055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3185 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbZJZOmo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 10:42:44 -0400
In-Reply-To: <20091025.142059.175260055.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The separation of Tx and Rx interrupt handling gives us the possibility to properly affinitize the Rx (heavy CPU consuming task) and Tx (low CPU consuming task) and to ensure that Tx work is done not long after the Tx interrupt without interference of Rx work thus letting the user benefit from Tx coalescing configuration in order to achieve the best performance in each specific scenario. This is most important in heavy load scenarios with mixed traffic (UDP + TCP for instance). If we didn't separate Tx and Rx interrupt handling Tx coalescing configuration was not worth much.

The mentioned above lead us to conclusion that it's more efficient not to use NAPI for freeing Tx buffers but to use a separate tasklet instead.

Best regards,
vlad

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
Sent: Sunday, October 25, 2009 11:21 PM
To: Vladislav Zolotarov
Cc: Eilon Greenstein; netdev@vger.kernel.org
Subject: Re: [PATCH net-next] bnx2x: Do Tx handling in a separate tasklet.

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 25 Oct 2009 14:19:42 +0200

> This patch moves the 'Tx interrupt work' of each Tx queue from the hardIRQ
> context to the separate low-latency tasklet. Otherwise there is a possibility
> of a software lockup situation in a Tx softIRQ as it handles freeing all skb's
> 'freed' in (hard)IRQ context.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Use NAPI, please...
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


