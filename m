From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [2.6.35-rc1 regression] tg3 vpd r/w failed
Date: Tue, 1 Jun 2010 16:28:47 -0700
Message-ID: <20100601232847.GA16274@mcarlson.broadcom.com>
References: <19461.26529.591960.912204@pilspetsen.it.uu.se>
 <20100601.153209.135521213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "mikpe@it.uu.se" <mikpe@it.uu.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100601.153209.135521213.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 01, 2010 at 03:32:09PM -0700, David Miller wrote:
> 
> Mikael I'm getting tired of continuing to add the proper
> mailing list CC: for your sparc bug reports.  Please make
> sure to add sparclinux@vger.kernel.org to your reports
> in the future.
> 
> Thanks.
> 
> > Booting 2.6.35-rc1 on a Sun Blade 2500 Red with builtin tg3 I get:
> > 
> > tg3.c:v3.110 (April 9, 2010)
> > PCI: Enabling device: (0000:00:03.0), cmd 2
> > ...
> > tg3 0000:00:03.0: vpd r/w failed.  This is likely a firmware bug on this device.  Contact the card vendor for a firmware update.
> > tg3 0000:00:03.0: vpd r/w failed.  This is likely a firmware bug on this device.  Contact the card vendor for a firmware update.
> > tg3 0000:00:03.0: vpd r/w failed.  This is likely a firmware bug on this device.  Contact the card vendor for a firmware update.
> > tg3 0000:00:03.0: eth0: Tigon3 [partno(none) rev 1002] (PCI:66MHz:64-bit) MAC address ...
> > tg3 0000:00:03.0: eth0: attached PHY is 5703 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> > tg3 0000:00:03.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> > tg3 0000:00:03.0: eth0: dma_rwctrl[763f0000] dma_mask[32-bit]
> > ...
> > tg3 0000:00:03.0: eth0: No firmware running
> > tg3 0000:00:03.0: eth0: Link is up at 100 Mbps, full duplex
> > tg3 0000:00:03.0: eth0: Flow control is on for TX and on for RX
> > 
> > The three 'vpd r/w failed' messages are new and did not occur with 2.6.34
> > or earlier kernels.

These messages are originating from the PCI layer.  It looks like your
device does not have NVRAM, which is a known issue.  I have an idea on
how to reduce the noise, but let me investigate it a little more before
I commit to it.
