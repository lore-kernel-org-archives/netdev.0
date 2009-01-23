From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 02/21] [next] qlge: Add new functions for signaling
	link up/down.
Date: Fri, 23 Jan 2009 23:23:33 +0000
Message-ID: <1232753014.3005.2.camel@achroite>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
	 <1232723799-8620-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-driver@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:56979 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757741AbZAWXXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 18:23:42 -0500
In-Reply-To: <1232723799-8620-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-23 at 07:16 -0800, Ron Mercer wrote:
> Centralize this call as it will also be used by firmware events.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge_main.c |   38 ++++++++++++++++++++++++--------------
>  1 files changed, 24 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index a530f5b..e6f9146 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -240,6 +240,24 @@ exit:
>  	return status;
>  }
>  
> +static void ql_link_on(struct ql_adapter *qdev)
> +{
> +	if (!netif_carrier_ok(qdev->ndev)) {
> +		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
> +		netif_carrier_on(qdev->ndev);
> +		netif_wake_queue(qdev->ndev);
> +	}
> +}
> +
> +static void ql_link_off(struct ql_adapter *qdev)
> +{
> +	if (netif_carrier_ok(qdev->ndev)) {
> +		QPRINTK(qdev, LINK, INFO, "Link is Down.\n");
> +		netif_carrier_off(qdev->ndev);
> +		netif_stop_queue(qdev->ndev);
> +	}
> +}
> +

netif_{wake,stop_queue}() are redundant with netif_carrier_{on,off}() so
I think this patch is (mostly?) unnecessary.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

