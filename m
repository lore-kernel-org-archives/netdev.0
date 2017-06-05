From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: bridge: fix potential NULL pointer dereference
Date: Tue, 6 Jun 2017 01:05:18 +0300
Message-ID: <840022de-3d31-4f62-aaaf-ba83d5c78ad7@cumulusnetworks.com>
References: <20170605213030.GA6272@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:33208 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdFEWFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 18:05:21 -0400
Received: by mail-wr0-f176.google.com with SMTP id v104so45244411wrb.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 15:05:21 -0700 (PDT)
In-Reply-To: <20170605213030.GA6272@embeddedgus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/17 00:30, Gustavo A. R. Silva wrote:
> Add NULL check before dereferencing pointer _p_ inside br_afspec().
> 
> Addresses-Coverity-ID: 1401872
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  net/bridge/br_netlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 1e63ec4..ad85a9c 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -776,7 +776,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
>  			goto out;
>  	}
>  
> -	if (afspec) {
> +	if (p && afspec) {
>  		err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
>  				afspec, RTM_SETLINK);
>  	}
> 

While I see a possible issue with the new bridge tunnel code (+CC Roopa), this is 
the wrong fix because there are legitimate use cases where p is null and br_afspec
is called.
We need to change the p->flags check in br_afspec()'s IFLA_BRIDGE_VLAN_TUNNEL_INFO case
to check for a NULL p first.

Thanks for the report!
