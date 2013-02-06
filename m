From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top
	of LRO
Date: Wed, 6 Feb 2013 23:34:20 +0000
Message-ID: <1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
References: <cover.1360191528.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>, Tushar,
	Sony Chacko <sony.chacko@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>, Carolyn, Jeff,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>, linux-driver@qlogic.com, Peter
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1360191528.git.mst@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-07 at 01:02 +0200, Michael S. Tsirkin wrote:
> At the moment, macvtap crashes are observed if macvtap is attached
> to an interface with LRO enabled.
> The crash in question is BUG() in macvtap_skb_to_vnet_hdr.
> This happens because several drivers set gso_size but not gso_type
> in incoming skbs.
> The following patches fix this for
> Additionally, cbf1de72324a8105ddcc3d9ce9acbc613faea17e is required
> to fix this for broadcom - would it make sense to cherry-pick
> this patch into 3.8?
> 
> I tested that the patch fixes the crash for ixgbe but
> don't have qlogic hardware to fix.  I also only tested TCP.
> 
> Feedback wellcome.

If we want to allow forwarding from LRO then net/ipv4/inet_lro.c also
needs to set gso_type.

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
