From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Sat, 11 Apr 2015 13:59:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504111340170.2449@ja.home.ssi.bg>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net> <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	matti.gottlieb@intel.com, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55300 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751820AbbDKLBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 07:01:37 -0400
In-Reply-To: <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 10 Apr 2015, Johannes Berg wrote:

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In certain 802.11 wireless deployments, there will be ARP proxies
> that use knowledge of the network to correctly answer requests.
> To prevent gratuitous ARP frames on the shared medium from being
> a problem, on such deployments wireless needs to drop them.
> 
> Enable this by providing an option called "drop_gratuitous_arp".
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 5f5c674e130a..5487d5e5191e 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -715,6 +715,14 @@ static int arp_process(struct sk_buff *skb)
>  	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
>  		goto out;
>  
> + /*
> +  *	For some 802.11 wireless deployments (and possibly other networks),
> +  *	there will be an ARP proxy and gratuitous ARP frames are attacks
> +  *	and thus should not be accepted.
> +  */
> +	if (IN_DEV_CONF_GET(in_dev, DROP_GRATUITOUS_ARP) && sip == tip)
> +		goto out;

	Does it happen for any pkt_type? IN_DEV_ARP_ACCEPT
is not ON by default, so new entries are not created but
update can happen at any time, even with simple request like
who-has OURIP tell PROXYIP and sha=hacker_mac sent by
attackers. Is that the only gap that needs to be protected
with this patch?

	May be only arptable_filter can help here to
protect ARP?

Regards

--
Julian Anastasov <ja@ssi.bg>
