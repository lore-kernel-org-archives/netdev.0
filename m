From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Kernel v3.0.8 igb driver dies when pulling network cable
Date: Wed, 23 Nov 2011 07:15:40 +0100
Message-ID: <4ECC8F8C.9030607@profihost.ag>
References: <4ECA4362.2050307@profihost.ag> <4ECA884C.5010706@intel.com> <4ECA936E.8060301@profihost.ag> <4ECAD3D4.4070306@intel.com> <4ECB6D1C.8010208@profihost.ag> <4ECC1592.60607@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stable Tree <stable@kernel.org>, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Jesse Brandeburg <jesse.brandeburg@intel.com> Bruce Allan"
	<bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ECC1592.60607@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex,

> It seems like there might be an issue with something specific to your
> board since I tried reproducing the issue here on an 82576 based adapter
> and the stable 3.0.9 kernel I have and I have not had much success.
but as it is working fine with the up2date igb module - it still was 
fixed ;-)

To reproduce try the following (gave me 100% success rate). Configure 
eth0 to DHCP, leave eth1 unconfigured.
Boot the system with lan cable plugged into eth1 !!
When the boot has finished switch the LAN cable from eth1 to eth0.

> I'm assuming the device that is failing is eth0.  I was wondering if you
> could send me the output of the following three commands so that I can
> do some further work to try and isolate the root cause for this issue:
> ethtool eth0
> ethtool -e eth0
> grep eth0 /proc/interrupts

Will send them as soon i have access to the machine again.

> The issue seems to be that your adapter is not detecting that the cable
> was unplugged.  This in turn is leaving stale packets on the Tx ring and
> is what is resulting in the dev_watchdog message you are seeing.
Are you sure? Cause when you look at the dmesg you'll see this:

igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

STACKTRACE!

igb 0000:0a:00.0: eth0: Reset adapter

eth0: no IPv6 routers present

igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

igb 0000:0a:00.0: eth0: Reset adapter

igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

So it happens when the cable is plugged in and NOT when i unplug it.

Stefan
