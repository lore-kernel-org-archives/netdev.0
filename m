From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/6] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Mon, 25 Mar 2013 19:50:44 +0400
Message-ID: <51507254.1080901@cogentembedded.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:37006 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758419Ab3CYPvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 11:51:43 -0400
Received: by mail-la0-f51.google.com with SMTP id fo13so11445336lab.24
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 08:51:41 -0700 (PDT)
In-Reply-To: <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-03-2013 15:08, Wei Liu wrote:

> The maximum packet including ethernet header that can be handled by netfront /
> netback wire format is 65535. Reduce gso_max_size accordingly.

> Drop skb and print warning when skb->len > 65535. This can 1) save the effort
> to send malformed packet to netback, 2) help spotting misconfiguration of
> netfront in the future.

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>   drivers/net/xen-netfront.c |   14 ++++++++++++++
>   1 file changed, 14 insertions(+)

> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 5527663..3ae9dc1 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	unsigned int len = skb_headlen(skb);
>   	unsigned long flags;
>
> +	/* Wire format of xen_netif_tx_request only supports skb->len
> +	 * < 64K, because size field in xen_netif_tx_request is
> +	 * uint16_t. If skb->len is too big, drop it and alert user about
> +	 * misconfiguration.
> +	 */
> +	if (unlikely(skb->len >= (uint16_t)(~0))) {

    Such types as 'uint16_t' are intended for userland -- use 'u16' instead. 
Better still, just use 0xffffu.

WBR, Sergei
