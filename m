From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] Move eth_mac_addr and eth_change_mtu
Date: Fri, 11 Jul 2003 22:56:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711215639.GN20424@parcelfarce.linux.theplanet.co.uk>
References: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk> <20030711182330.GC16037@gtf.org> <20030711182530.GH20424@parcelfarce.linux.theplanet.co.uk> <3F0F24B1.5050200@pobox.com> <20030711210522.GM20424@parcelfarce.linux.theplanet.co.uk> <3F0F294F.4060804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F0F294F.4060804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 05:17:03PM -0400, Jeff Garzik wrote:
> Matthew Wilcox wrote:
> >On Fri, Jul 11, 2003 at 04:57:21PM -0400, Jeff Garzik wrote:
> >
> >>Well, I don't see/understand this next-stage, so elaboration would be 
> >>nice.  As-is, I do not support merging this patch.
> >
> >
> >It's the next stage you're calling for -- move these functions:
> >
> >        dev->change_mtu         = eth_change_mtu;
> >        dev->hard_header        = eth_header;
> >        dev->rebuild_header     = eth_rebuild_header;
> >        dev->set_mac_address    = eth_mac_addr;
> >        dev->hard_header_cache  = eth_header_cache;
> >        dev->header_cache_update= eth_header_cache_update;
> >        dev->hard_header_parse  = eth_header_parse;
> >
> >into netdev_ops.  Which means each driver will need to see them.
> 
> Drivers don't need to see them now, they shouldn't need to see them 
> after netdev_ops.
> 
> It's hidden by ether_setup.

Umm.  Technically, yes.  Seems a bit ugly to assign to the netdev_ops
struct which is shared between the devices.  Won't _break_ anything
(unless some crazed person has a driver which drives the ethernet and
token ring versions of the same chip ;-)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
