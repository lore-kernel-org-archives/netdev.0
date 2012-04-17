From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 'No PHY devices' loading issue
Date: Tue, 17 Apr 2012 11:50:07 -0700
Message-ID: <20120417185007.GA3742@mcarlson.broadcom.com>
References: <20120417141856.GA19507@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Josh Boyer" <jwboyer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120417141856.GA19507@zod.bos.redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 10:18:57AM -0400, Josh Boyer wrote:
> Hi Matt and Michael,
> 
> I'm seeing an odd issue with the tg3 driver on one of my development
> machines.  I've tried kernels 3.2.10, 3.3.0, 3.3.1, 3.3.2 and 3.4-rc3
> and they all seem to exhibit this issue now.  When the machine boots
> and the tg3 driver is loaded, it fails to find a PHY and then reports
> 'Problem fetching invariants of chip'.  If I do a rmmod/modprobe of
> tg3 after login, the probe seems to work fine and ethernet works as
> expected.  You can see this in the dmesg below:
> 
> [jwboyer@vader ~]$ dmesg | grep tg3
> [    2.084969] tg3.c:v3.122 (December 7, 2011)
> [    2.093511] tg3 mdio bus: probed
> [    2.093513] tg3 0000:03:00.0: No PHY devices
> [    2.093531] tg3 0000:03:00.0: Problem fetching invariants of chip, aborting
> [   90.824697] tg3.c:v3.122 (December 7, 2011)
> [   90.857068] tg3 mdio bus: probed
> [   90.862540] tg3 0000:03:00.0: eth0: Tigon3 [partno(BCM57788) rev 57780001] (PCI Express) MAC address 18:03:73:e6:01:88
> [   90.862547] tg3 0000:03:00.0: eth0: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=300:01)
> [   90.862552] tg3 0000:03:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> [   90.862557] tg3 0000:03:00.0: eth0: dma_rwctrl[76180000] dma_mask[64-bit]
> [   90.919961] tg3 0000:03:00.0: irq 47 for MSI/MSI-X
> [   91.863311] tg3 0000:03:00.0: p3p1: Link is down
> [   92.864348] tg3 0000:03:00.0: p3p1: Link is up at 100 Mbps, full duplex
> [   92.864352] tg3 0000:03:00.0: p3p1: Flow control is on for TX and on for RX
> 
> It has worked on some of the older kernels without the need for the
> manual rmmod/modprobe step, so it seems to be somewhat timing related.
> I'm not sure if there is a module load ordering issue, but that doesn't
> seem to be the case.  I can't explain why a later modprobe would work
> just fine though.
> 
> Do you have any thoughts on how to go about debugging/fixing this?  I'd
> be happy to test and provide whatever information you need.

The 57788 uses the broadcom phylib module.  For some reason, it isn't
available the first module load attempt.  A while ago, code was added to
phylib to request modules from userspace if the particular phy support
code wasn't already loaded.  It looks like this mechanism isn't working
too well the first time through.

Can you reproduce the problem if you run 'rmmod broadcom' and then
reload tg3?
