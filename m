From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH stable] ipv6: restrict neighbor entry creation to output flow
Date: Wed, 14 Aug 2013 17:00:54 +0200
Message-ID: <20130814150054.GB2723@order.stressinduktion.org>
References: <abab9dc5af4b61da70672b99ad80175b94b4ec68.1376488215.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, jiri@resnulli.us, dbanerje@akamai.com,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51470 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404Ab3HNPAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 11:00:55 -0400
Content-Disposition: inline
In-Reply-To: <abab9dc5af4b61da70672b99ad80175b94b4ec68.1376488215.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 10:53:27AM -0300, Marcelo Ricardo Leitner wrote:
> This patch is based on 3.2.y branch, the one used by reported. Please let me
> know if it should be different. Thanks.
> 
> ---8<---
> 
> Commit 0d6a77079c475033cb622c07c5a880b392ef664e introduced a regression on
> which routes to local delivery would not work anymore. Like this:
> 
>     $ ip -6 route add local 2001::/64 dev lo
>     $ ping6 -c1 2001::9
>     PING 2001::9(2001::9) 56 data bytes
>     ping: sendmsg: Invalid argument
> 
> As this is a local delivery, that commit would not allow the creation of a
> neighbor entry and thus the packet cannot be sent.
> 
> But as TPROXY scenario actually needs to avoid the neighbor entry creation only
> for input flow, this patch now limits previous patch to input flow, keeping
> output as before that patch.
> 
> Reported-by: Debabrata Banerjee <dbavatar@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, thanks Marcelo!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

David, this patch is for all stable kernels except the 3.10 series.
It does not apply cleanly throughout the whole longterm kernels but the
changes should not be too difficult to adapt. Do you take care of this
or can we do something to ease this process?

Thanks!
