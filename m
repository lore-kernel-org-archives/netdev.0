From: Darren Williams <dsw@gelato.unsw.edu.au>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Fri, 7 Jan 2005 11:17:44 +1100
Message-ID: <20050107001743.GH17027@cse.unsw.EDU.AU>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU> <20041220161552.2b88aa3d.davem@davemloft.net> <16839.30796.413939.333935@wombat.chubb.wattle.id.au> <20050106151910.4d51673e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com,
        mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050106151910.4d51673e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David

On Thu, 06 Jan 2005, David S. Miller wrote:

> 
> Peter, let me know if this patch solves your PHY link up problem
> too.
> 
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2005/01/06 14:53:55-08:00 davem@nuts.davemloft.net 
> #   [TG3]: Return 0 when PHY read times out, not all-ones.
> #   
> #   Noticed by Peter Chubb.
> #   
> #   Signed-off-by: David S. Miller <davem@davemloft.net>
> # 
> # drivers/net/tg3.c
> #   2005/01/06 14:53:07-08:00 davem@nuts.davemloft.net +1 -1
> #   [TG3]: Return 0 when PHY read times out, not all-ones.
> # 
> diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
> --- a/drivers/net/tg3.c	2005-01-06 14:54:21 -08:00
> +++ b/drivers/net/tg3.c	2005-01-06 14:54:21 -08:00
> @@ -485,7 +485,7 @@
>  		udelay(80);
>  	}
>  
> -	*val = 0xffffffff;
> +	*val = 0x0;
>  
>  	frame_val  = ((PHY_ADDR << MI_COM_PHY_ADDR_SHIFT) &
>  		      MI_COM_PHY_ADDR_MASK);

No, if I revert back to an earlier driver the link comes
up OK printing:
  tg3: eth0: Link is up at 1000 Mbps, full duplex.
  tg3: eth0: Flow control is off for TX and off for RX.
after a short delay. With the current dirver I do not
see any prinks from tg3_link_report about the state
of the link.

Darren

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
