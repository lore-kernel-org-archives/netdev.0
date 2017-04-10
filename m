From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next V2 5/7] s390/qeth: improve endianness handling
Date: Mon, 10 Apr 2017 15:16:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFCAAFB@AcuExch.aculab.com>
References: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
 <20170407071538.63253-6-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "jwi@linux.vnet.ibm.com" <jwi@linux.vnet.ibm.com>,
        "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
        "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
        "raspl@linux.vnet.ibm.com" <raspl@linux.vnet.ibm.com>
To: 'Ursula Braun' <ubraun@linux.vnet.ibm.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:50727 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753340AbdDJPQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:16:36 -0400
In-Reply-To: <20170407071538.63253-6-ubraun@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun
> Sent: 07 April 2017 08:16
> Avoid endianness warnings reported by sparse by (1) using endianness
> conversions for assigning and using network packet fields, and (2)
> removing unnecessary endianness conversions from qeth_l3_rebuild_skb. No
> functional changes.
...
> -	if (*p == ETH_P_8021Q)
> +	if (be16_to_cpu(*p) == ETH_P_8021Q)
...

This is clearly different on little-endian systems.
Also (probably) better written as:

	if (*p == cpu_to_be16(ETH_P_8021Q))

so that the constant can by byteswapped.

	David
