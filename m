From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next V2 2/2] xen-netfront: split
 event channels support for Xen frontend driver
Date: Wed, 22 May 2013 09:13:59 +0100
Message-ID: <519C9A6702000078000D8026@nat28.tlf.novell.com>
References: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
 <1369161310-9529-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>, <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:45736 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193Ab3EVIOE convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Wed, 22 May 2013 04:14:04 -0400
In-Reply-To: <1369161310-9529-3-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 21.05.13 at 20:35, Wei Liu <wei.liu2@citrix.com> wrote:
> @@ -1550,22 +1651,18 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>  		goto grant_rx_ring_fail;
>  	info->rx_ring_ref = err;
>  
> -	err = xenbus_alloc_evtchn(dev, &info->evtchn);
> +	if (feature_split_evtchn)
> +		err = setup_netfront_split(info);
> +	else
> +		err = setup_netfront_single(info);
>  	if (err)
>  		goto alloc_evtchn_fail;

You could easily fall back to single event channel mode here if split
setup fails.

Jan
