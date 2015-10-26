From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 7/8] xen-netback: add support for a multi-queue
 hash mapping table
Date: Mon, 26 Oct 2015 17:05:51 +0000
Message-ID: <20151026170551.GG18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-8-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [66.165.176.89] ([66.165.176.89]:19079 "EHLO SMTP.CITRIX.COM"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751874AbbJZRFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 13:05:53 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-8-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:24AM +0100, Paul Durrant wrote:
> Advertise the capability to handle a hash mapping specified by the
> frontend (see netif.h for details).
> 
> Add an ndo_select() entry point so that, of the frontend does specify a

"if the frontend ..."

> hash mapping, the skb hash is extracted and mapped to a queue. If no
> mapping is specified then the fallback queue selection function is
> called so there is no change in behaviour.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
[...]
> +static void xen_hash_mapping_changed(struct xenbus_watch *watch,
> +				     const char **vec, unsigned int len)
> +{
> +	struct xenvif *vif = container_of(watch, struct xenvif,
> +					  hash_mapping_watch);
> +
> +	xen_net_read_multi_queue_hash_mapping(vif);

Is it safe / correct to not stop the vif before changing mapping table?

Wei.
