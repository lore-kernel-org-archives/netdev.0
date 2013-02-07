From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top
	of LRO
Date: Thu, 7 Feb 2013 16:20:46 +0000
Message-ID: <1360254046.3605.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1360191528.git.mst@redhat.com>
	<1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
	<1360207111.28557.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>, Don, Tushar,
	Sony Chacko <sony.chacko@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>, Eilon, linux-driver@qlogic.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1360207111.28557.47.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-06 at 19:18 -0800, Eric Dumazet wrote:
> On Wed, 2013-02-06 at 23:34 +0000, Ben Hutchings wrote:
> 
> > If we want to allow forwarding from LRO then net/ipv4/inet_lro.c also
> > needs to set gso_type.
> 
> Then, what is dev_disable_lro() purpose ?

The purpose was to disable LRO when forwarding because they weren't
compatible.

If the consensus now is that the modifications made by LRO+TSO are
acceptable in a bridge/router, then we should get rid of
dev_disable_lro() and set both gso_size & gso_type on all LRO receive
paths.

If the consensus is still that we must preserve packets exactly (aside
from the usual modifications by IP routers) then LRO should be disabled
on all devices for which forwarding is enabled.  (Also, we really ought
to keep a count of the number of forwarders and use that in
netdev_fix_features(), rather than doing a one-time disable.)

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
