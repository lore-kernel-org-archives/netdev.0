From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next 1/2] bonding: Verify RX LACPDU has proper dest mac-addr
Date: Tue, 24 Feb 2015 18:38:36 +0100
Message-ID: <54ECB71C.4000807@redhat.com>
References: <1424742610-6656-1-git-send-email-maheshb@google.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:42032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752796AbbBXRis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 12:38:48 -0500
In-Reply-To: <1424742610-6656-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 02:50 AM, Mahesh Bandewar wrote:
> The 802.1AX standard states:
> "The DA in LACPDUs is the Slow_Protocols_Multicast address."
> 
> This patch enforces that and drops LACPDUs with destination MAC
> addresses other than Slow_Protocols_Multicast address
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
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
