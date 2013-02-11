From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2-net-3.8 0/3] fix kernel crash with macvtap on top of
 LRO
Date: Sun, 10 Feb 2013 20:15:12 -0500 (EST)
Message-ID: <20130210.201512.326994514517897067.davem@davemloft.net>
References: <cover.1360236441.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, john.r.fastabend@intel.com,
	jacob.e.keller@intel.com, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1360236441.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 7 Feb 2013 15:12:56 +0200

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

Applied to 'net', thanks.
