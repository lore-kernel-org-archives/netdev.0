From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [E1000-devel] Sporadic packet loss observed with newer in-kernel
 drivers (5.2.15-k)
Date: Mon, 2 Mar 2015 14:49:06 -0800 (PST)
Message-ID: <alpine.NEB.2.11.1503021442250.17818@chris.i8u.org>
References: <906FBB8A-98FE-4879-99C5-98EDA7BCB3CD@numascale.com> <9B4A1B1917080E46B64F07F2989DADD653478AB3@ORSMSX114.amr.corp.intel.com> <3F039C86-94C5-42AE-A939-B4A155495216@numascale.com> <9B4A1B1917080E46B64F07F2989DADD653479BB4@ORSMSX114.amr.corp.intel.com>
 <C59DCFE4-0C0B-4371-B4C5-B2AC43519DE1@numascale.com> <9B4A1B1917080E46B64F07F2989DADD65347CC59@ORSMSX114.amr.corp.intel.com> <54F41F38.1060505@numascale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Steffen Persvold <sp@numascale.com>, netdev@vger.kernel.org
To: Daniel J Blueman <daniel@numascale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-87-25-Oregon.hfc.comcastbusiness.net ([75.148.87.25]:62680
	"EHLO chris.i8u.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbCBWtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:49:07 -0500
In-Reply-To: <54F41F38.1060505@numascale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Mar 2015, Daniel J Blueman wrote:

> Hi Todd,
>
> Following up on this, since the packet loss doesn't occur when using the 
> out-of-tree driver but does when using the mainline driver, it's more 
> plausible that there's a driver behavioural difference causing this.
>
> After instrumenting MDI activity, a bunch of differences come from 
> force_speed_duplex() being called when the hardware is first 
> initialised, wherein hw->mac.autoneg is 0 only with the mainline driver 
> along this path:
>
> igb_setup_copper_link+0x2a5/0x2c0
> igb_copper_link_setup_igp+0xb7/0x210
> igb_setup_copper_link_82575+0xd4/0x180
> igb_setup_link+0x36/0x1c0
> igb_init_hw_82575+0xba/0x330
> igb_reset+0x15f/0x5e0
> igb_sriov_reinit+0x88/0xc0
> igb_pci_enable_sriov+0x115/0x200
> igb_probe+0x4ae/0x11a0
> local_pci_probe+0x40/0xa0
>
> The same 6 setup_copper_link() calls occur (three per on-board adapter) 
> in the out-of-tree driver, however hw->mac.autoneg is always set; this 
> also fits with our findings that triggering autoneg prevent the packet loss.
>
> What's the expectation with value of hw->mac.autoneg?

If this is the case, it sounds like all your packets are being dropped
at boot time. Did you ever complete your bisecting of the kernel?

Also, do you have direct factory support? I'd suggest filing an IPS if
you want this issue tracked.

-- 
todd.fujinaka@intel.com
