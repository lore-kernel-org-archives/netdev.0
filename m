From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Thu, 09 Nov 2006 15:04:36 -0800 (PST)
Message-ID: <20061109.150436.94557169.davem@davemloft.net>
References: <5cac192f0611091333w5740810bhe1966d6391c6d46a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23732
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424233AbWKIXE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:04:28 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0611091333w5740810bhe1966d6391c6d46a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please use GREG_STAT_* instead of magic constants for the
interrupt mask and ACK register writes.  In fact, there are
some questionable values you use, in particular this one:

+static inline void gem_ack_int(struct gem *gp)
+{
+	writel(0x3f, gp->regs + GREG_IACK);
+}

There is no bit defined in GREG_STAT_* for 0x08, but you
set it in this magic bitmask.  It is another reason not
to use magic constants like this :-)

Also, if you need to use an attachment to get the tabbing
right, that's fine, but please also provide a copy inline
so that it is easy to quote the patch for review purposes.
It's a truly a pain in the rear to quote things when you use
a binary attachment.

I'd like these very simple and straightforward issues to
be worked out before I even begin to review the actual
locking change itself.
