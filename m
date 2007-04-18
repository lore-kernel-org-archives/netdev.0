From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [NETLINK] Don't attach callback to a going-away netlink socket
Date: Wed, 18 Apr 2007 12:17:07 +0400
Message-ID: <20070418081707.GA29267@2ka.mipt.ru>
References: <4625D3D2.9030507@sw.ru>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33736 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbXDRISL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 04:18:11 -0400
Content-Disposition: inline
In-Reply-To: <4625D3D2.9030507@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2007 at 12:16:18PM +0400, Pavel Emelianov (xemul@sw.ru) wrote:
> Sorry, I forgot to put netdev and David in Cc when I first sent it.
> 
> There is a race between netlink_dump_start() and netlink_release()
> that can lead to the situation when a netlink socket with non-zero
> callback is freed.

Out of curiosity, why not to fix a netlink_dump_start() to remove
callback in error path, since in 'no-error' path it removes it in
netlink_dump().

And, btw, can release method be called while socket is being used, I
thought about proper reference counters should prevent this, but not
100% sure with RCU dereferencing of the descriptor.

-- 
	Evgeniy Polyakov
