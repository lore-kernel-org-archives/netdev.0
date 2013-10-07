From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCHv1 net] xen-netback: transition to CLOSED when removing a
 VIF
Date: Mon, 7 Oct 2013 14:28:58 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD012A294@AMSPEX01CL01.citrite.net>
References: <1381150519-14557-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8640 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754532Ab3JGO3J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 10:29:09 -0400
In-Reply-To: <1381150519-14557-1-git-send-email-david.vrabel@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Vrabel [mailto:david.vrabel@citrix.com]
> Sent: 07 October 2013 13:55
> To: xen-devel@lists.xen.org
> Cc: David Vrabel; Konrad Rzeszutek Wilk; Boris Ostrovsky;
> netdev@vger.kernel.org; Ian Campbell; Wei Liu; Paul Durrant
> Subject: [PATCHv1 net] xen-netback: transition to CLOSED when removing a
> VIF
> 
> From: David Vrabel <david.vrabel@citrix.com>
> 
> If a guest is destroyed without transitioning its frontend to CLOSED,
> the domain becomes a zombie as netback was not grant unmapping the
> shared rings.
> 
> When removing a VIF, transition the backend to CLOSED so the VIF is
> disconnected if necessary (which will unmap the shared rings etc).
> 
> This fixes a regression introduced by
> 279f438e36c0a70b23b86d2090aeec50155034a9 (xen-netback: Don't destroy
> the netdev until the vif is shut down).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Paul Durrant <Paul.Durrant@citrix.com>
> ---
>  drivers/net/xen-netback/xenbus.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index b45bce2..1b08d87 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -39,11 +39,15 @@ static int connect_rings(struct backend_info *);
>  static void connect(struct backend_info *);
>  static void backend_create_xenvif(struct backend_info *be);
>  static void unregister_hotplug_status_watch(struct backend_info *be);
> +static void set_backend_state(struct backend_info *be,
> +			      enum xenbus_state state);
> 
>  static int netback_remove(struct xenbus_device *dev)
>  {
>  	struct backend_info *be = dev_get_drvdata(&dev->dev);
> 
> +	set_backend_state(be, XenbusStateClosed);
> +
>  	unregister_hotplug_status_watch(be);
>  	if (be->vif) {
>  		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
> --
> 1.7.2.5

Looks good to me.

Reviewed-by:  Paul Durrant <paul.durrant@citrix.com>

  Paul
