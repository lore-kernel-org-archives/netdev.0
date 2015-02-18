From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v4 1/6] bonding: Verify RX LACPDU has proper dest
 mac-addr
Date: Wed, 18 Feb 2015 13:58:28 +0100
Message-ID: <54E48C74.9020304@redhat.com>
References: <1424243866-26989-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbbBRM6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 07:58:40 -0500
In-Reply-To: <1424243866-26989-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 08:17 AM, Mahesh Bandewar wrote:
> The 802.1AX standard states:
> "The DA in LACPDUs is the Slow_Protocols_Multicast address."
> 
> This patch enforces that and drops LACPDUs with destination MAC
> addresses other than Slow_Protocols_Multicast address
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>    Initial version
> v2-v4:
>    Rebase
> 
>  drivers/net/bonding/bond_3ad.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index cfc4a9c1000a..9b436696b95e 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2485,6 +2485,9 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>  	if (skb->protocol != PKT_TYPE_LACPDU)
>  		return RX_HANDLER_ANOTHER;
>  
> +	if (!MAC_ADDRESS_EQUAL(eth_hdr(skb)->h_dest, lacpdu_mcast_addr))
> +		return RX_HANDLER_ANOTHER;
> +
>  	lacpdu = skb_header_pointer(skb, 0, sizeof(_lacpdu), &_lacpdu);
>  	if (!lacpdu)
>  		return RX_HANDLER_ANOTHER;
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
