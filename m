From: "David Schwartz" <davids@webmaster.com>
Subject: RE: TOE brain dump
Date: Wed, 6 Aug 2003 14:13:47 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <MDEHLPKNGKAHNMBLJOLKOEOCEOAA.davids@webmaster.com>
References: <20030806143956.B15543@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Andy Isaacson" <adi@hexapodia.org>,
	"Jesse Pollard" <jesse@cats-chateau.net>
In-Reply-To: <20030806143956.B15543@hexapodia.org>
List-Id: netdev.vger.kernel.org


> This statement is completely false.  Ethernet switches *do* read the
> packet into memory before starting transmission.

	Some do. Some don't. Some are configurable.

> This must be so,
> because an Ethernet switch does not propagate runts, jabber frames, or
> frames with an incorrect ethernet crc.

	If they use cut-through switching, they do. Some use adaptive switching,
which means they use cut-through switching but change to store and forward
if there are too many runts, jabber frames, bad CRCs, and so on.

	Obviously, you can't always do a cut-through. If the target port is busy,
cut-through is impossible. If the ports are different speeds, cut-through is
impossible. The Intel 510T switch for my home network does adaptive
switching with configurable error thresholds. In fact, it's even smarter
than that, with an intermediate mode that suppresses runts without doing a
full store and forward. See:
http://www.intel.com/support/express/switches/23188.htm

> If the switch starts
> transmission before it's received the last bit, it is provably
> impossible for it to avoid propagating crc-failing-frames; ergo,
> switches must have the entire packet on hand before starting
> transmission.

	Except not all switches always avoid propogating bad frames.

	DS
