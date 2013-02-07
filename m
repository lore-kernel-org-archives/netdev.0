From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top
	of LRO
Date: Thu, 7 Feb 2013 22:31:35 +0000
Message-ID: <1360276295.3605.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
	<1360207111.28557.47.camel@edumazet-glaptop>
	<1360254046.3605.8.camel@bwh-desktop.uk.solarflarecom.com>
	<20130207.131420.1211188723341167971.davem@davemloft.net>
	<20130207213315.GB5064@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jitendra.kalsaria@qlogic.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, eilong@broadcom.com,
	john.r.fastabend@intel.com, john.ronciak@intel.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com,
	David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	jacob.e.keller@intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130207213315.GB5064@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-07 at 23:33 +0200, Michael S. Tsirkin wrote:
> On Thu, Feb 07, 2013 at 01:14:20PM -0500, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Thu, 7 Feb 2013 16:20:46 +0000
> > 
> > > If the consensus is still that we must preserve packets exactly (aside
> > > from the usual modifications by IP routers) then LRO should be disabled
> > > on all devices for which forwarding is enabled.
> > 
> > I believe this is still undoubtedly the consensus.
> 
> But we don't need to preserve the packets when passing them to macvtap
> (which discards all this info smashing the packet into a single buffer anyway),
> correct?

macvtap_skb_to_vnet_hdr() certainly seems to be trying to preserve all
the packet information.

> If true LRO with macvtap might be useful and so the patchset is probably
> still the right thing to do to fix the macvtap crash. Makes sense?

If macvtap+virtio_net is expected to re-segment then this is fine.  But
I don't see why it should be different from other uses of macvlan.

> We might want to add code to forward LRO status from macvlan
> (not macvtap) back to the lowerdev, so that setting up forwarding
> from macvlan disables LRO on the lowerdev, but that seems like another
> issue.

I think it's the same issue!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
