From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] if_link: Add VF multicast promiscuous mode control
Date: Tue, 20 Jan 2015 11:53:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CACF10D@AcuExch.aculab.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Hiroshi Shimamoto' <h-shimamoto@ct.jp.nec.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hiroshi Shimamoto
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> 
> Add netlink directives and ndo entry to control VF multicast promiscuous mode.
> 
> Intel ixgbe and ixgbevf driver can handle only 30 multicast MAC addresses
> per VF. It means that we cannot assign over 30 IPv6 addresses to a single
> VF interface on VM. We want thousands IPv6 addresses in VM.
> 
> There is capability of multicast promiscuous mode in Intel 82599 chip.
> It enables all multicast packets are delivered to the target VF.

A lot of ethernet chips (certainly older ones) used a hash for the
multicast filter. So the hardware filter was never perfect.

I even know of one that needed to be told the addresses and used
those to set the hash bits.
For that device I generated a canonical set of MAC addresses (one
for each multicast hash) and did a software count of how many times
each one was needed for each of the enabled multicasts.

My guess is that 'multicast promiscuous mode' is always valid
and should be enabled by the relevant low level driver when
any table setup fails because there are too many entries.

I actually suspect that most systems want all the multicasts
that occur at any moderate rate on the local network segment.

	David
