From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Fri, 14 Oct 2011 08:34:23 +0200
Message-ID: <20111014063423.GQ1830@secunet.com>
References: <20111011110842.GC1830@secunet.com>
 <20111011111027.GE1830@secunet.com>
 <20111012.170805.2172804476308993385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47267 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab1JNGe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 02:34:26 -0400
Content-Disposition: inline
In-Reply-To: <20111012.170805.2172804476308993385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 05:08:05PM -0400, David Miller wrote:
> 
> You really can't do this, it's going to kill all of the memory savings from
> storing metrics in the inetpeer cache.
> 
> Every input route is going to have it's metrics COW'd with this change.
> 

Ok, I missed this completely. So if input and output routes share the
inetpeer information and we don't want to copy, we might not use the
(learned) pmtu informations on the inetpeer for input routes. So
for input routes, dst_mtu() could return dst->ops->default_mtu()
instead of the mtu informations stored on the metric. Are there other
(better) solutions?
