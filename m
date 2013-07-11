From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: skb_warn_bad_offload related to IPv6 in 3.9.9+
Date: Thu, 11 Jul 2013 22:37:37 +0100
Message-ID: <1373578657.2085.20.camel@bwh-desktop.uk.level5networks.com>
References: <51DEFEEB.1080408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58027 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756669Ab3GKVhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 17:37:42 -0400
In-Reply-To: <51DEFEEB.1080408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-11 at 11:52 -0700, Ben Greear wrote:
> This kernel has local patches applied...but I don't think it has anything
> that would cause this....
> 
> The wanlink module is something we added.  It is now GPL, but code is
> not upstream.  I don't think it's in directly related to the splat though...
>
> Only saw one splat, and system remains stable as far as we can tell.
>
> ------------[ cut here ]------------
> WARNING: at /home/greearb/git/linux-3.9.dev.y/net/core/dev.c:2179 skb_warn_bad_offload+0xc2/0xcb()
> Hardware name: X7DBU
> e1000e: caps=(0x00000000700003a9, 0x0000000000000000) len=2942 data_len=1428 gso_size=1428 gso_type=16 ip_summed=1
[...]

The skb requires TSO, which requires that ip_summed = CHECKSUM_PARTIAL.
But ip_summed = CHECKSUM_UNNECESSARY.

To me, this suggests that the receiving device i.e. wanlink has some
kind of broken LRO that can't be turned off...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
