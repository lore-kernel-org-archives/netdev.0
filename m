From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2 V2] macvlan fdb replace support
Date: Fri, 19 Jul 2013 09:18:55 -0700
Message-ID: <20130719091855.6c763231@nehalam.linuxnetplumber.net>
References: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com>
	<1374247208-8226-2-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42928 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172Ab3GSQS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 12:18:58 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so4584936pab.38
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 09:18:58 -0700 (PDT)
In-Reply-To: <1374247208-8226-2-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Jul 2013 17:20:08 +0200
Thomas Richter <tmricht@linux.vnet.ibm.com> wrote:

> Add support for iproute2 command 'bridge fdb replace ...'.
> The rtnletlink call back function ndo_fdb_add will be called
> with the NLM_F_REPLACE flag set.
> Simply return -EOPNOTSUP.
> 
> Resubmitted because net-next was closed last week.
> 
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> ---
>  drivers/net/macvlan.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 18373b6..74907f5 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -597,6 +597,9 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  	if (!vlan->port->passthru)
>  		return -EOPNOTSUPP;
>  
> +	if (flags & NLM_F_REPLACE)
> +		return -EOPNOTSUPP;
> +
>  	if (is_unicast_ether_addr(addr))
>  		err = dev_uc_add_excl(dev, addr);
>  	else if (is_multicast_ether_addr(addr))

What about bridge that also uses netlink FDB interface?
