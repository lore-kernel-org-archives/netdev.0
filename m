From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 02/15] 6lowpan: next header is not properly set
 upon decompression of a UDP header.
Date: Tue, 23 Oct 2012 09:05:36 +0200
Message-ID: <508641C0.10001@computer.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org> <1350965397-12384-3-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:51099 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756477Ab2JWHKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:10:13 -0400
In-Reply-To: <1350965397-12384-3-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 06:09 AM, Tony Cheneau wrote:
> This causes a drop of the UDP packet.
> 
> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
> ---
>  net/ieee802154/6lowpan.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 6d42c17..b53a71a4 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -913,9 +913,12 @@ lowpan_process_data(struct sk_buff *skb)
>  	}
>  
>  	/* UDP data uncompression */
> -	if (iphc0 & LOWPAN_IPHC_NH_C)
> +	if (iphc0 & LOWPAN_IPHC_NH_C) {
>  		if (lowpan_uncompress_udp_header(skb))
>  			goto drop;
> +		hdr.nexthdr = UIP_PROTO_UDP;
> +	}
> +

Superfluous newline.

>  
>  	/* Not fragmented package */
>  	hdr.payload_len = htons(skb->len);
> 
