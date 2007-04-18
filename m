From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [NETLINK] Don't attach callback to a going-away netlink socket
Date: Wed, 18 Apr 2007 13:14:18 +0400
Message-ID: <20070418091418.GA7117@2ka.mipt.ru>
References: <4625D3D2.9030507@sw.ru> <20070418081707.GA29267@2ka.mipt.ru> <4625D7A8.5030209@sw.ru> <20070418084416.GB4241@2ka.mipt.ru> <4625DEFC.7040701@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	devel@openvz.org, Patrick McHardy <kaber@trash.net>,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45765 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422689AbXDRJPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 05:15:16 -0400
Content-Disposition: inline
In-Reply-To: <4625DEFC.7040701@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2007 at 01:03:56PM +0400, Pavel Emelianov (xemul@sw.ru) wrote:
> > Yes, you are right, that it will not be freed in netlink_release(), 
> > but it will be freed in netlink_dump() after it is processed (in no-error 
> > path only though).
> > 
> 
> But error path will leak it. On success path we would have
> a leaked packet in sk_write_queue, since we did't see it in
> skb_queue_purge() while doing netlink_release().
> 
> Of course we can place the struts in code to handle the case
> when we have a released socket with the attached callback, but
> it is more correct (IMHO) not to allow to attach the callbacks
> to dead sockets.

That is why I've asked why such approach is used but not freeing
callback in errror (well, no-dump name is better to describe that path)
path, and more generally, why callback is attached, but not freed in the
function, but instead is freed next time dump started.

-- 
	Evgeniy Polyakov
