From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2-net-3.8 0/3] fix kernel crash with
 macvtap on top of LRO
Date: Thu, 7 Feb 2013 17:05:16 +0000
Message-ID: <1360256716.3605.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1360236441.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, Jacob,
	Keller <jacob.e.keller@intel.com>, Tushar,
	Sony Chacko <sony.chacko@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>, Carolyn, Jeff,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, linux-driver@qlogic.com, Peter
To: "Michael S. Tsirkin" <mst@redhat.com>, "David S. Miller"
	<davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1360236441.git.mst@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-07 at 15:12 +0200, Michael S. Tsirkin wrote:
> At the moment, macvtap crashes are observed if macvtap is attached
> to an interface with LRO enabled.
> The crash in question is BUG() in macvtap_skb_to_vnet_hdr.
> This happens because several drivers set gso_size but not gso_type
> in incoming skbs.
> This didn't use to be the case: with intel cards on 3.2 and older
> kernels, with qlogic - on 3.4 and older kernels, so it's a regression if
> not a recent one.
> The following patches fix this for qlogic, broadcom and intel drivers.
> 
> I tested that the patch fixes the crash for ixgbe but
> don't have qlogic/broadcom hardware to test.
> I also only tested TCPv4.
> 
> Please review, and consider for 3.8.
> 
> Changes from v1:
> 	- added missing htons as suggested by Eric
> 	- backported the relevant bits from
> 	  cbf1de72324a8105ddcc3d9ce9acbc613faea17e for bnx2x

I still don't think macvtap should behave inconsistently with forwarding
and the bridge device.  We need a consensus as to whether transformation
by LRO is allowable before making changes one way or the other.  If
we're going to allow it then inet_lro also needs this fix.

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
