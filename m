From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC
 filters
Date: Fri, 27 Mar 2015 18:45:09 +0100
Message-ID: <20150327184509.71f3d3f7@griffin>
References: <1427409698.18540.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mahesh Bandewar <maheshb@google.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbbC0RpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 13:45:14 -0400
In-Reply-To: <1427409698.18540.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Mar 2015 17:41:38 -0500, Dan Williams wrote:
> The broadcast MAC is supposed to be allowed whenever the device
> has an IPv4 address, otherwise ARP requests get dropped on the
> floor.  If ndo_set_rx_mode (and thus
> ipvlan_set_multicast_mac_filter()) gets called after the address
> was added, it blows away the broadcast MAC address in
> mac_filters that was added at IPv4 address addition.  Fix that.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
>  drivers/net/ipvlan/ipvlan_main.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 4f4099d..d34f580 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -241,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
>  
>  		bitmap_copy(ipvlan->mac_filters, mc_filters,
>  			    IPVLAN_MAC_FILTER_SIZE);
> +
> +		if (ipvlan->ipv4cnt)
> +			ipvlan_set_broadcast_mac_filter(ipvlan, true);

It would be probably better to set the bit in mc_filters before copying
over to ipvlan->mac_filters. But it's not a big deal as bitmap_copy is
not atomic and it is changed by the second patch anyway.

I see not much value in having the two patches separate and would
squash them but it's not a big deal, either.

Reviewed-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
