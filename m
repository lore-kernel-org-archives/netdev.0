From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Mon, 20 Jan 2014 18:35:51 +0400
Message-ID: <52DD3447.7000504@cogentembedded.com>
References: <1390187144-15495-1-git-send-email-shangw@linux.vnet.ibm.com> <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com
To: Gavin Shan <shangw@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:53595 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbaATOfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 09:35:55 -0500
Received: by mail-la0-f45.google.com with SMTP id b8so5664810lan.32
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 06:35:54 -0800 (PST)
In-Reply-To: <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-01-2014 7:05, Gavin Shan wrote:

> We possiblly retrieve the adapter's statistics during EEH recovery

    Only "possibly".

> and that should be disallowed. Otherwise, it would possibly incur
> replicate EEH error and EEH recovery is going to fail eventually.
> The patch checks if the PCI device is off-line before statistic
> retrieval.

> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index c8eafbf..b0e72fb 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4288,6 +4288,17 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
>   	struct port_info *p = netdev_priv(dev);
>   	struct adapter *adapter = p->adapter;
>
> +	/*
> +	 * We possibly retrieve the statistics while the PCI
> +	 * device is off-line. That would cause the recovery
> +	 * on off-lined PCI device going to fail. So it's
> +	 * reasonable to block it during the recovery period.
> +	 */

    The multi-line comment style in the networking code is somewhat special:

/* bla
  * bla
  */

WBR, Sergei
