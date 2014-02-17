From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 4/4] xen-netback: skip IPv4 and IPv6 interfaces
Date: Mon, 17 Feb 2014 14:36:55 +0000
Message-ID: <53021E87.6020607@citrix.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com> <1392433180-16052-5-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, <kvm@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	<linux-kernel@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59183 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbaBQOhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 09:37:21 -0500
In-Reply-To: <1392433180-16052-5-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a valid scenario to put IP addresses on the backend VIFs:

http://wiki.xen.org/wiki/Xen_Networking#Routing

Also, the backend is not necessarily Dom0, you can connect twou guests 
with backend/frontend pairs.

Zoli

On 15/02/14 02:59, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> The xen-netback driver is used only to provide a backend
> interface for the frontend. The link is the only thing we
> use, and that is used internally for letting us know when the
> xen-netfront is ready, when it switches to XenbusStateConnected.
>
> Note that only when the both the xen-netfront and xen-netback
> are both in state XenbusStateConnected will xen-netback allow
> userspace on the host (backend) to bring up the interface. Enabling
> and disabling the interface will simply enable or disable NAPI
> respectively, and that's used for IRQ communication set up with
> the xen event channels.
>
> Cc: Paul Durrant <Paul.Durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: xen-devel@lists.xenproject.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>   drivers/net/xen-netback/interface.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index d380e3f..07e6fd2 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -351,7 +351,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>
>   	eth_hw_addr_random(dev);
>   	memcpy(dev->dev_addr, xen_oui, 3);
> -	dev->priv_flags |= IFF_BRIDGE_NON_ROOT;
> +	dev->priv_flags |= IFF_BRIDGE_NON_ROOT | IFF_SKIP_IP;
>   	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
>
>   	netif_carrier_off(dev);
>
