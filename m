From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/9] veth: convert to 64 bit statistics
Date: Fri, 10 Jun 2011 17:34:19 +0100
Message-ID: <1307723659.2815.9.camel@bwh-desktop>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.449670103@vyatta.com>
	 <1307584841.22348.528.camel@localhost>
	 <20110608202241.52ce68ae@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49742 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab1FJQeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 12:34:22 -0400
In-Reply-To: <20110608202241.52ce68ae@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-08 at 20:22 -0700, Stephen Hemminger wrote:
> On Thu, 09 Jun 2011 03:00:41 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > On Wed, 2011-06-08 at 17:53 -0700, Stephen Hemminger wrote:
> > > Not much change, device was already keeping per cpu statistics.
> > > Use recent 64 statistics interface.
> > [...]
> > 
> > It's also going to need to use u64_stats_sync functions.
> > 
> > Ben.
> > 
> 
> No veth is doing per-cpu update therefore the new code has the same guarantee
> as the old code.

Per-cpu statistics avoid the problem of races between writers without
using expensive atomic operations.  They don't solve the problem of
races between writer and reader (on 32-bit systems).

For example, if veth_get_stats() races with a receive or transmit that
increments a value from 0x00000001ffffffff to 0x0000000200000000, it may
see the value as 0x00000002ffffffff.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

