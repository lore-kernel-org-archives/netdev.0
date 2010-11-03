From: Ralf Baechle <ralf@linux-mips.org>
Subject: Unaligned accesses in AVR32 kernel
Date: Wed, 3 Nov 2010 15:32:06 +0000
Message-ID: <20101103153206.GA20830@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, Simon Eatough <simon.eatough@gmail.com>
To: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hans-Christian,

I received a bug report for some networking code from which it seems as
if the AVR32 kernel doesn't fixup exceptions caused by missaligned kernel
accesses either in software or hardware.  This is a problem as there in
the networking stack there is no general guarantee that all multi-byte
header fields such as ARP or IP headers will aligned.  Networking drivers
are supposed to make a decent attempt to place packets at a suitable
address but there is no guarantee.  The mkiss.c driver gets that wrong
which I'm fixing but fundamentally you want to add automated fixing of
unaligned exception to the AVR32 kernel.  See arch/mips/kernel/unaligned.c.

Cheers,

  Ralf
