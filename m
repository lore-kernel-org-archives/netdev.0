From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Move eth_mac_addr and eth_change_mtu
Date: Fri, 11 Jul 2003 17:17:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0F294F.4060804@pobox.com>
References: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk> <20030711182330.GC16037@gtf.org> <20030711182530.GH20424@parcelfarce.linux.theplanet.co.uk> <3F0F24B1.5050200@pobox.com> <20030711210522.GM20424@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030711210522.GM20424@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Fri, Jul 11, 2003 at 04:57:21PM -0400, Jeff Garzik wrote:
> 
>>Well, I don't see/understand this next-stage, so elaboration would be 
>>nice.  As-is, I do not support merging this patch.
> 
> 
> It's the next stage you're calling for -- move these functions:
> 
>         dev->change_mtu         = eth_change_mtu;
>         dev->hard_header        = eth_header;
>         dev->rebuild_header     = eth_rebuild_header;
>         dev->set_mac_address    = eth_mac_addr;
>         dev->hard_header_cache  = eth_header_cache;
>         dev->header_cache_update= eth_header_cache_update;
>         dev->hard_header_parse  = eth_header_parse;
> 
> into netdev_ops.  Which means each driver will need to see them.

Drivers don't need to see them now, they shouldn't need to see them 
after netdev_ops.

It's hidden by ether_setup.


> I thought I could justify moving these functions already on the grounds
> that if you were looking for the definition of eth_change_mtu(),
> net_init.c would be a much less likely place to look than
> net/ethernet/eth.c

If you're gonna do that, move all of ether_setup, alloc_etherdev, etc. 
Don't just move two out of ~10 functions.

	Jeff
