From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Mon, 20 Dec 2004 22:19:36 -0800
Message-ID: <20041220221936.056b6812.davem@davemloft.net>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
	<20041220161552.2b88aa3d.davem@davemloft.net>
	<16839.30796.413939.333935@wombat.chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
In-Reply-To: <16839.30796.413939.333935@wombat.chubb.wattle.id.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Dec 2004 12:11:40 +1100
Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> It doesn't work because tg3_readphy sets bmsr to 0xffffffff even if it
> can't read the value.  This breaks that loop early; and because
> BBMSR_LSTATUS is set, all sorts of things happen before the card is ready.
> 
> Why is tg3_readphys returning 0xffffffff if it can't read a value anyway?

Because callers are not supposed to depend upon the value being set
to anything valid if tg3_readphy() returns an error.

I thought it should never be returning an error at this spot.  The
PHY should always return a valid value within PHY_BUSY_LOOPS.  If
MI_COM_BUSY is staying set for such a long time that's a pretty
serious problem.

Taking a peek at the bcm5700 driver by Broadcom, they handle all PHY read
timeouts the way your patch does in this one spot, by setting the returned
value to zero.  So it seems the device can time out like that in these
situations, and your patch is something close to the correct fix.

Good catch Peter, I'll think some more about this and probably end
up using something similar to your second patch.

Thanks.
