From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] bnx2: turn off the network statck during initialization
Date: Thu, 16 Aug 2012 22:25:21 +0100
Message-ID: <1345152321.2832.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345141295-7589-1-git-send-email-Jiang.Wang@riverbed.com>
	 <1345143431.6916.36.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CEE05A0D7856E14880AD5560634EBEA834DB2ABC@SFO1EXC-MBXP06.nbttech.com>
	 <1345145318.6916.42.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CEE05A0D7856E14880AD5560634EBEA834DB2B40@SFO1EXC-MBXP06.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chaitanya Lala <Chaitanya.Lala@riverbed.com>,
	"Francis St. Amant" <Francis.St.Amant@riverbed.com>
To: Jiang Wang <Jiang.Wang@riverbed.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CEE05A0D7856E14880AD5560634EBEA834DB2B40@SFO1EXC-MBXP06.nbttech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-16 at 20:28 +0000, Jiang Wang wrote:
[...]
> Also, I have another comment related to link state.
> 
> Right now, the bnx2 driver powers up the device in bnx2_init_board(),
> regardless the netif_carrier is on or off. This may introduce
> following inconsistent behaviors:
> 1) suppose the cable is plugged in to the NIC and the other end is
> connected to a switch
> 2) user powers up the box
> 3) the Linux does not bring up the interface; i.e, ifconfig ethx shows
> it is down

Most distributions will bring up all interfaces at boot, by default.

> 4) ethtool ethx will show no link
> 5) if the user goes to check the light on the physical NIC, he will
> see the green link light is ON. That means the link is up, right? 
> 
> I think it is better to power down the device until bnx2_open is
> called. In this way, ethtool report and the physical link light will
> be consistent. 
[...]

In general, a physical network interface may need to be enabled to allow
management traffic to a BMC, even when the interface is in the 'down'
state on the host.

The link state should be considered unknown whenever the interface is
down, and /sys/class/net/$IFACE/carrier is not readable then.  However
ETHTOOL_GLINK is not expected to fail in this way, and must always
return 0 (down) or 1 (up).  The convention (which is now enforced in
ethtool_get_link()) is that when the interface is down it should always
return 0.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
