From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT 2/3] 8139cp: don't mix software and chip stats
Date: Thu, 17 Mar 2005 00:42:02 +0100
Message-ID: <20050316234202.GB27664@electric-eye.fr.zoreil.com>
References: <20050316150431.6888fe55@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050316150431.6888fe55@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> The rx_frags statistic is a software statistic and not a hardware statistic
> and it is pasted on to the end. Since the statistic is really a warning about
> overlength frames, it shouldn't be in the ethtool stats.  
> 
> Francois, could you make sure 8169 and 8139cp report fragments the same way.

(not sure I understood the question)

Do you mean that the r8169 driver should provide something like
cp_rx_err_acct() ?

[...]
> diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
> --- a/drivers/net/8139cp.c	2005-03-16 14:55:11 -08:00
> +++ b/drivers/net/8139cp.c	2005-03-16 14:55:11 -08:00
[...]
> +		/* we don't support incoming fragmented frames.
> +		 * instead, we attempt to ensure that the
> +		 * pre-allocated RX skbs are properly sized such
> +		 * that RX fragments are never encountered
> +		 */
> +		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag)
> +			|| (status & (RxError | RxErrFIFO))) {
>  			cp_rx_err_acct(cp, rx_tail, status, len);
>  			goto rx_next;
>  		}

I'll verify how the 8169 behaves wrt the Rx fifo error indication. It can
apparently be set a bit too much (i.e. on every packet).

--
Ueimor
