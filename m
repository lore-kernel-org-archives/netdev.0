From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH] bridge: reset bridge mtu after deleting an interface
Date: Fri, 13 Mar 2015 19:12:52 -0700
Message-ID: <55039924.3050609@cumulusnetworks.com>
References: <20150313140822.GA30448@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35542 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbCNCMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:12:54 -0400
Received: by pabyw6 with SMTP id yw6so5433999pab.2
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 19:12:54 -0700 (PDT)
In-Reply-To: <20150313140822.GA30448@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/15, 7:08 AM, Venkat Venkatsubra wrote:
> On adding an interface br_add_if() sets the MTU to the min of
> all the interfaces. Do the same thing on removing an interface too
> in br_del_if.
>
> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> ---
>   net/bridge/br_if.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index b087d27..1849d96 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -563,6 +563,8 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>   	 */
>   	del_nbp(p);
>   
> +	dev_set_mtu(br->dev, br_min_mtu(br));
> +
>   	spin_lock_bh(&br->lock);
>   	changed_addr = br_stp_recalculate_bridge_id(br);
>   	spin_unlock_bh(&br->lock);
This looks good to me.

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
