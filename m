From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH] tg3_msi() and weakly ordered memory
Date: Tue, 14 Jun 2005 11:04:25 -0700
Message-ID: <20050614180425.GE24371@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972067F0804@NT-IRVA-0741.brcm.ad.broadcom.com> <20050614154021.GA24371@esmail.cup.hp.com> <1118767397.7059.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <iod00d@hp.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1118767397.7059.19.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2005 at 09:43:17AM -0700, Michael Chan wrote:
...
> Something like:
> 
> if (sblk->status_tag != tp->last_tag)
> 	clear_interrupt();
> 	netif_rx_schedule();
> 
> This way we don't have to clear the SD_STATUS_UPDATED bit. I will
> experiment with this and see if it works well.

that sounds good - thanks.

> I don't think we are reading the index on every iteration. In tg3_rx(),
> we read it at the beginning before the loop, and one more time if we
> have caught up with the hw index before exiting the loop.

oh - sorry - my bad. Same is true for tg3_tx().

And I just noticed I'm smoking crack on "nested locks" too...
one is "lock" and the other is "tx_lock".
*sigh* - need more sleep.

> I mildly disagree. I think we should maximize the amount of work done in
> tg3_poll(). For example, reading the rx_producer index one more time
> when we have caught up with hw index before exiting the loop is a good
> thing IMO.

ok.

thanks,
grant
