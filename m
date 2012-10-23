From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 05/15] 6lowpan: use short IEEE 802.15.4 addresses
 for broadcast destination
Date: Tue, 23 Oct 2012 09:08:19 +0200
Message-ID: <50864263.2020307@computer.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org> <1350965397-12384-6-git-send-email-tony.cheneau@amnesiak.org>
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
	by vger.kernel.org with ESMTP id S1756651Ab2JWHKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:10:14 -0400
In-Reply-To: <1350965397-12384-6-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 06:09 AM, Tony Cheneau wrote:
> It is intended that the IEEE 802.15.4 standard uses the 0xFFFF short address (2
> bytes) for message broadcasting.
> 
> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
> ---
>  net/ieee802154/6lowpan.c |   21 +++++++++++++--------
>  1 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 49d91df..8a2ee95 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -577,21 +577,26 @@ static int lowpan_header_create(struct sk_buff *skb,
>  	 * this isn't implemented in mainline yet, so currently we assign 0xff
>  	 */
>  	{
> +		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
> +
>  		/* prepare wpan address data */
>  		sa.addr_type = IEEE802154_ADDR_LONG;
>  		sa.pan_id = 0xff;
> -
> -		da.addr_type = IEEE802154_ADDR_LONG;
> -		da.pan_id = 0xff;
> -
> -		memcpy(&(da.hwaddr), daddr, 8);
>  		memcpy(&(sa.hwaddr), saddr, 8);
>  
> -		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
> +		da.pan_id = 0xff;
> +		/* if the destination address is the broadcast address,
> +		   use short address */

David likes comments in the networking code to look

		/* Like
		 * this
		 */

Note that the comment is closed on a line by itself. There's an example
at the top of this hunk.
