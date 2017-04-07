From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/7] s390/qeth: improve endianness handling
Date: Fri, 7 Apr 2017 11:25:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFC85F3@AcuExch.aculab.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
 <20170405084015.35772-6-ubraun@linux.vnet.ibm.com>
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
Received: from smtp-out6.electric.net ([192.162.217.195]:60641 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753883AbdDGLZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 07:25:13 -0400
In-Reply-To: <20170405084015.35772-6-ubraun@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun
> Sent: 05 April 2017 09:40
> From: Hans Wippel <hwippel@linux.vnet.ibm.com>
> 
> Avoid endianness warnings reported by sparse by (1) using endianness
> conversions for assigning and using network packet fields, and (2)
> removing unnecessary endianness conversions from qeth_l3_rebuild_skb. No
> functional changes.
> 
> Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> ---
>  drivers/s390/net/qeth_core.h      |  4 ++--
>  drivers/s390/net/qeth_core_main.c | 11 +++++-----
>  drivers/s390/net/qeth_l3_main.c   | 46 +++++++++++++++++++--------------------
>  drivers/s390/net/qeth_l3_sys.c    |  4 ++--
>  4 files changed, 33 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
> index 22aa2cd..6764ab9 100644
> --- a/drivers/s390/net/qeth_core.h
> +++ b/drivers/s390/net/qeth_core.h
> @@ -844,9 +844,9 @@ static inline int qeth_get_ip_version(struct sk_buff *skb)
>  {
>  	__be16 *p = &((struct ethhdr *)skb->data)->h_proto;
> 
> -	if (*p == ETH_P_8021Q)
> +	if (be16_to_cpu(*p) == ETH_P_8021Q)
>  		p += 2;
> -	switch (*p) {
> +	switch (be16_to_cpu(*p)) {
>  	case ETH_P_IPV6:

These are definitely 'functional changes' on LE systems.

Also it is generally better to byteswap the constants.

	David
