From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [Xen-devel] [RFC PATCH 2/6] netback: add module unload function.
Date: Fri, 13 Jan 2012 17:57:47 +0000
Message-ID: <4F10709B.8070804@cantab.net>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com> <1326473949-22389-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47038 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab2AMR5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 12:57:55 -0500
Received: by yenq4 with SMTP id q4so365492yen.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 09:57:55 -0800 (PST)
In-Reply-To: <1326473949-22389-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/12 16:59, Wei Liu wrote:
> Enables users to unload netback module.
[...]
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 26af7b7..dd10c0d 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1653,5 +1653,19 @@ failed_init:
>  
>  module_init(netback_init);
>  
> +static void __exit netback_exit(void)
> +{
> +	int i;
> +	for (i = 0; i < xen_netbk_group_nr; i++) {
> +		struct xen_netbk *netbk = &xen_netbk[i];
> +		del_timer(&netbk->net_timer);

This needs to be del_timer_sync().

> +		kthread_stop(netbk->task);
> +	}
> +	vfree(xen_netbk);
> +	page_pool_destroy();
> +	xenvif_xenbus_exit();
> +}
