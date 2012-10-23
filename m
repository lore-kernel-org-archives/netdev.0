From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 11/15] 6lowpan: modify udp compression/uncompression
 to match the standard
Date: Tue, 23 Oct 2012 09:22:48 +0200
Message-ID: <508645C8.1090908@computer.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org> <1350965397-12384-12-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:42969 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756539Ab2JWHZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:25:13 -0400
In-Reply-To: <1350965397-12384-12-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 06:09 AM, Tony Cheneau wrote:
> The previous code would just compress the UDP header and send the compressed
> UDP header along with the uncompressed one.
> 
> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
> ---
>  net/ieee802154/6lowpan.c |   36 +++++++++++++++++++++++++++++++++---
>  1 files changed, 33 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 9711038..9c7ac2e 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
(...)

>  		/* copy checksum */
>  		memcpy(&uh->check, &skb->data[0], 2);
>  		skb_pull(skb, 2);
> +
> +		/* UDP lenght needs to be infered from the lower layers
> +		   here, we obtain the hint from the remaining size of the
> +		   frame */
> +		uh->len = htons(skb->len + sizeof(struct udphdr));
> +		pr_debug("uncompressed UDP length: src = %d", uh->len);

Multi-line comment style as per earlier comment.
