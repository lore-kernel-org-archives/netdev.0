From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Tue, 3 Sep 2013 19:27:36 +0200
Message-ID: <20130903172736.GB21729@order.stressinduktion.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch> <52261A12.3060203@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Fabio Estevam <festevam@gmail.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35019 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759357Ab3ICR1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 13:27:38 -0400
Content-Disposition: inline
In-Reply-To: <52261A12.3060203@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 11:19:14AM -0600, Stephen Warren wrote:
> On 09/03/2013 05:37 AM, Thomas Graf wrote:
> > Allocating skbs when sending out neighbour discovery messages
> > currently uses sock_alloc_send_skb() based on a per net namespace
> > socket and thus share a socket wmem buffer space.
> > 
> > If a netdevice is temporarily unable to transmit due to carrier
> > loss or for other reasons, the queued up ndisc messages will cosnume
> > all of the wmem space and will thus prevent from any more skbs to
> > be allocated even for netdevices that are able to transmit packets.
> > 
> > The number of neighbour discovery messages sent is very limited,
> > use of alloc_skb() bypasses the socket wmem buffer size enforcement
> > while the manual call to skb_set_owner_w() maintains the socket
> > reference needed for the IPv6 output path.
> > 
> > This patch has orginally been posted by Eric Dumazet in a modified
> > form.
> 
> Tested-by: Stephen Warren <swarren@nvidia.com>
> 
> Although I do note something slightly odd:
> 
> next-20130830 had an issue, and reverting V1 of this patch solved it.
> 
> However, in next-20130903, if I revert the revert of V1 of this patch, I
> don't see any issue; it appears that the problem was some interaction
> between V1 of this patch and something else in next-20130830.
> 
> Either way, this patch doesn't seem to introduce any issue when applied
> on top of either next-20130830 with V1 reverted, or on top of
> next-20130903, so it's fine.

Could either of you run the v1 version of the patch with CONFIG_PROVE_LOCKING
enabled? I also do think there is some side-effect we don't understand yet.

Thanks,

  Hannes
