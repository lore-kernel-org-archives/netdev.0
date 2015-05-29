From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net] xen: netback: read hotplug script once at start of
 day.
Date: Fri, 29 May 2015 17:28:42 +0100
Message-ID: <556893BA.9030300@citrix.com>
References: <1432916693-21121-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:52453 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbbE2Q3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 12:29:00 -0400
In-Reply-To: <1432916693-21121-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/05/15 17:24, Ian Campbell wrote:
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -235,6 +235,7 @@ static int netback_remove(struct xenbus_device *dev)
>  		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
>  		xen_unregister_watchers(be->vif);
>  		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
> +		kfree(be->vif->hotplug_script);

Should this kfree() be in xenvif_free()?

>  		xenvif_free(be->vif);
>  		be->vif = NULL;
>  	}

David
