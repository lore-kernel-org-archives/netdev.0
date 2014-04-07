From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [tipc] dest_name_check() is racy (potential security hole)
Date: Mon, 7 Apr 2014 10:08:52 +0200
Message-ID: <20140407080852.GC3676@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <20140406043934.GW18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:64422 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaDGIIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 04:08:54 -0400
Content-Disposition: inline
In-Reply-To: <20140406043934.GW18016@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 06, 2014 at 05:39:34AM +0100, Al Viro wrote:
> According to the comment in front of it, it "prevents restricted configuration
> commands from being issued by unauthorized users".  Makes sense, right?
> Except that it obviously doesn't provide any security whatsoever, because
> the value we'd read from the iovec is immediately discarded and later
> we reread it again.
> 
> There is nothing to stop the caller from spawning a threar that would flip
> the bits in question back and forth, while the parent keeps calling sendmsg().
> Sooner or later we will have dest_name_check() pick the harmless value,
> with subsequent memcpy_fromiovecend() picking the modified one.

Ack, but as of commit 5902385a2440a55f005b266c93e0bb9398e5a62b ("tipc: obsolete the
remote management feature) this is no longer an issue. We missed to remove the
TIPC_CFG_SRV/CAP_NET_ADMIN check in that commit aswell.

//W
