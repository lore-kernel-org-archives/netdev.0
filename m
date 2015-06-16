From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 1/2] net: mvneta: introduce tx_csum_limit property
Date: Tue, 16 Jun 2015 11:59:05 +0000
Message-ID: <20150616115905.GB2917@io.lakedaemon.net>
References: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
 <1434378443-23029-2-git-send-email-simon.guinot@sequanux.org>
 <20150615164952.4f2f4dab@free-electrons.com>
 <20150615155440.GS4853@kw.sim.vm.gnt>
 <20150616120034.510b0030@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Guinot <simon.guinot@sequanux.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	stable@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pmta2.delivery5.ore.mailhop.org ([54.186.218.12]:46458 "HELO
	pmta2.delivery5.ore.mailhop.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754528AbbFPL7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 07:59:10 -0400
Content-Disposition: inline
In-Reply-To: <20150616120034.510b0030@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas, Simon,

On Tue, Jun 16, 2015 at 12:00:34PM +0200, Thomas Petazzoni wrote:
> On Mon, 15 Jun 2015 17:54:41 +0200, Simon Guinot wrote:
> > > The current armada-370-neta would limit the HW checksumming features to
> > > packets smaller than 1600 bytes, while a new armada-xp-neta would not
> > > have this limit.
> > 
> > This was also my first idea. But by doing this, we take the risk of
> > losing the HW checksumming feature with jumbo frames on some currently
> > working Armada XP setups. This may happen for example if a user is able
> > to update the kernel but not the on-board DTB. In order to fix a feature
> > on a SoC, we are breaking the DTB-kernel compatibility for the very same
> > feature on an another SoC. I am not sure it is OK.

Frankly, this isn't a realistic scenario.  We've said from day one that
if the dtb is provided with the board that it needs to be updateable.
For exactly these kinds of situations.  Also, Thomas' assessment is
correct, everyone we've ever spoken to is keeping the dtb in sync with
the kernel.

As long as a board with the old dtb boots a newer kernel without
crashing, then it's fine.  afaict in this situation, the updated driver
should limit HW checksumming for packets >1600 bytes if the compatible
string is 'armada-370-neta'.  Regardless of actual SoC underneath.
If the driver gets 'armada-xp-neta' then there is no checksum limit.

Users with an Armada XP SoC and an old dtb will need to upgrade the dtb
in order to make use of HW checksumming on jumbo packets with newer
kernels.  Seems sane to me.

thx,

Jason.
