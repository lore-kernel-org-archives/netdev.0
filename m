From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix possible corruption in bpqether driver
Date: Wed, 02 Sep 2009 23:10:33 -0700 (PDT)
Message-ID: <20090902.231033.243002174.davem@davemloft.net>
References: <20090902085841.GA5910@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	thomas@osterried.de, jann@gmx.de
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090902085841.GA5910@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 2 Sep 2009 09:58:52 +0100

> The bpq ether driver is modifying the data art of the skb by first
> dropping the KISS byte (a command byte for the radio) then prepending the
> length + 4 of the remaining AX.25 packet to be transmitted as a little
> endian 16-bit number.  If the high byte of the length has a different
> value than the dropped KISS byte users of clones of the skb may observe
> this as corruption.  This was observed with by running listen(8) -a which
> uses a packet socket which clones transmit packets.  The corruption will
> then typically be displayed for as a KISS "TX Delay" command for AX.25
> packets in the range of 252..508 bytes or any other KISS command for
> yet larger packets.
> 
> Fixed by using skb_cow to create a private copy should the skb be cloned.
> Using skb_cow also allows us to cleanup the old logic to ensure sufficient
> headroom in the skb.
> 
> While at it, replace a return of 0 from bpq_xmit with the proper constant
> NETDEV_TX_OK which is now being used everywhere else in this function.
> 
> Affected: all 2.2, 2.4 and 2.6 kernels.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> Reported-by: Jann Traschewski <jann@gmx.de>

Applied to net-next-2.6, thanks!
