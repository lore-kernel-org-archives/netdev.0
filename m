From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: skb_linearize
Date: Sun, 16 Sep 2012 16:07:12 +0100
Message-ID: <1347808032.13258.275.camel@deadeye.wl.decadent.org.uk>
References: <20120916091747.GA23775@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30341 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751459Ab2IPPHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2012 11:07:17 -0400
In-Reply-To: <20120916091747.GA23775@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-16 at 12:17 +0300, Michael S. Tsirkin wrote:
> I notice that dev_hard_start_xmit might invoke
> __skb_linearize e.g. if device does not support NETIF_F_SG.
> 
> This in turn onvokes __pskb_pull_tail, and
> documentation of __pskb_pull_tail says:
>   &sk_buff MUST have reference count of 1.
> 
> I am guessing 'reference count' means users in this context, right?
> IIUC this is because it modifies skb in a way that
> isn't safe if anyone else is looking at the skb.
> 
> 
> However, I don't see what guarantees that reference
> count is 1 when dev_hard_start_xmit invokes
> linearize. In particular it calls dev_queue_xmit_nit
> which could queue packets on a network tap.
> 
> Could someone help me understand please?

Reference count here means references to struct sk_buff itself.  The
header area and data fragments are allowed to be shared.

dev_queue_xmit_nit() clones the skb for each tap, so the reference count
on the original skb remains 1.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
