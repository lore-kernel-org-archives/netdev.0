From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 23/42] drivers/net/wireless/libertas: Adjust confusing
 if indentation
Date: Thu, 05 Aug 2010 16:50:44 -0500
Message-ID: <1281045044.18688.5.camel@dcbw.foobar.com>
References: <Pine.LNX.4.64.1008052223340.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1008052223340.31692@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-05 at 22:23 +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> At the point of the patched code, err has already been tested, so it is
> only worthwhile to test it again in the if branches where it is changed.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r disable braces4@
> position p1,p2;
> statement S1,S2;
> @@
> 
> (
> if (...) { ... }
> |
> if (...) S1@p1 S2@p2
> )
> 
> @script:python@
> p1 << r.p1;
> p2 << r.p2;
> @@
> 
> if (p1[0].column == p2[0].column):
>   cocci.print_main("branch",p1)
>   cocci.print_secs("after",p2)
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: Dan Williams <dcbw@redhat.com>

> ---
>  drivers/net/wireless/libertas/if_spi.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
> index fe3f080..3965c6c 100644
> --- a/drivers/net/wireless/libertas/if_spi.c
> +++ b/drivers/net/wireless/libertas/if_spi.c
> @@ -800,14 +800,16 @@ static int lbs_spi_thread(void *data)
>  			goto err;
>  		}
>  
> -		if (hiStatus & IF_SPI_HIST_CMD_UPLOAD_RDY)
> +		if (hiStatus & IF_SPI_HIST_CMD_UPLOAD_RDY) {
>  			err = if_spi_c2h_cmd(card);
>  			if (err)
>  				goto err;
> -		if (hiStatus & IF_SPI_HIST_RX_UPLOAD_RDY)
> +		}
> +		if (hiStatus & IF_SPI_HIST_RX_UPLOAD_RDY) {
>  			err = if_spi_c2h_data(card);
>  			if (err)
>  				goto err;
> +		}
>  
>  		/* workaround: in PS mode, the card does not set the Command
>  		 * Download Ready bit, but it sets TX Download Ready. */
