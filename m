From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 1/3] net: mvneta: introduce compatible string
 "marvell, armada-xp-neta"
Date: Thu, 18 Jun 2015 09:31:51 +0200
Message-ID: <20150618093151.6efcd32a@free-electrons.com>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
	<1434547162-6275-2-git-send-email-simon.guinot@sequanux.org>
	<55818E64.20007@free-electrons.com>
	<55818F10.8030304@free-electrons.com>
	<20150617170112.GD2917@io.lakedaemon.net>
	<20150617224312.3bfc80d9@free-electrons.com>
	<20150617213926.GE2917@io.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:53739 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753260AbbFRHbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 03:31:55 -0400
In-Reply-To: <20150617213926.GE2917@io.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jason Cooper,

On Wed, 17 Jun 2015 21:39:26 +0000, Jason Cooper wrote:

> Odd, I'd use that as an example of the process working.  ;-)  we have
> everyone using 'armada-370-neta' for a given block.  We discovered that
> the original IP block (on the 370s) had a limitation (no hw checksum
> for greater than 1600 bytes).  A newer version of the IP block (XP)
> doesn't have the limitation.
> 
> So we change the driver to honor the limit for the 370 compatible
> string.  We create a new compatible string for xp where the block
> doesn't have the limitation.
> 
> How did the process fail?

Because now all Armada XP users of jumbo frames are looking the HW
checksum on their jumbo frames, which you can consider to be a
regression: it was working, it is no longer working.

Of course, since it falls back to SW checksumming, it still "works",
but some users can complain of the performance penalty and consider it
to be a regression.

If on Armada XP, we had used for the beginning:

	compatible = "marvell,armada-xp-neta", "marvell,armada-370-neta"

with only marvell,armada-370-neta supported originally, we could have
added this fix without breaking HW checksumming on jumbo frames for
Armada XP users.

So I'm sorry, but the process indeed failed, because Armada XP users
keeping their old Device Tree blob will see a regression.

> I'm not seeing where backwards compatibility was broken?  A device with
> an old dtb booting a newer kernel gets a bugfix.  In the case of an XP
> board with an old dtb (armada-370-neta), the hardware still works, but
> not optimally.  Upgrading the dtb will enable hw checksumming for jumbo
> packets.

"not optimally" is still a breakage.

Again, I personally don't care about DT backward compatibility as I
think it's a stupid requirement. But I like to point out to the
DT backward compatibility fanatics when it was actually broken :-)

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
