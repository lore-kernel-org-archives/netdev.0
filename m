From: Jiang Wang <Jiang.Wang@riverbed.com>
Subject: RE: [PATCH] bnx2: turn off the network statck during initialization
Date: Thu, 16 Aug 2012 21:48:01 +0000
Message-ID: <CEE05A0D7856E14880AD5560634EBEA834DB2C2B@SFO1EXC-MBXP06.nbttech.com>
References: <1345141295-7589-1-git-send-email-Jiang.Wang@riverbed.com>
 <1345143431.6916.36.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CEE05A0D7856E14880AD5560634EBEA834DB2ABC@SFO1EXC-MBXP06.nbttech.com>
 <1345145318.6916.42.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CEE05A0D7856E14880AD5560634EBEA834DB2B40@SFO1EXC-MBXP06.nbttech.com>
 <1345151593.6916.62.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chaitanya Lala <Chaitanya.Lala@riverbed.com>,
	"Francis St. Amant" <Francis.St.Amant@riverbed.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345151593.6916.62.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2012-08-16 at 20:28 +0000, Jiang Wang wrote:
> Also, I have another comment related to link state.
> 
> Right now, the bnx2 driver powers up the device in bnx2_init_board(), 
> regardless the netif_carrier is on or off.

We actually don't power up the device.  bnx2_init_board() just probes the device.  If link is already up, it will stay up.  If it is down, it will stay down.

---- I see. I was confused by the name of bnx2_set_power_state()  and I think the PHY is actually powered up by bnx2_reset_nic, right?

> This may introduce following inconsistent behaviors:
> 1) suppose the cable is plugged in to the NIC and the other end is 
> connected to a switch
> 2) user powers up the box

The link may already be up before or when you power up the box because of management firmware (iLO, etc) or WoL.

---- OK.

> 3) the Linux does not bring up the interface; i.e, ifconfig ethx shows 
> it is down
> 4) ethtool ethx will show no link
> 5) if the user goes to check the light on the physical NIC, he will 
> see the green link light is ON. That means the link is up, right?
> 
> I think it is better to power down the device until bnx2_open is 
> called. In this way, ethtool report and the physical link light will 
> be consistent.

We cannot power it down.  If link is up, it is up for a reason (e.g. it is an iLO port, etc).

---- OK. 


Thanks.
