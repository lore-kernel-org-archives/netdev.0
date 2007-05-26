From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] Avoid switch on long long in s2io driver
Date: Sat, 26 May 2007 19:04:08 +0200
Message-ID: <200705261904.09028.mb@bu3sch.de>
References: <jebqg8kllk.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Schwab <schwab@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48589
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbXEZREM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 13:04:12 -0400
In-Reply-To: <jebqg8kllk.fsf@sykes.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 26 May 2007 10:58:15 Andreas Schwab wrote:
> A switch on long long causes gcc to generate a reference to __ucmpdi2 on
> ppc32.  Avoid that by casting to int, since the value is only a small
> integer anyway.
> 
> Signed-off-by: Andreas Schwab <schwab@suse.de>
> 
> ---
>  drivers/net/s2io.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.22-rc1/drivers/net/s2io.c
> ===================================================================
> --- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-13 11:03:28.000000000 +0200
> +++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-13 12:52:49.000000000 +0200
> @@ -2898,7 +2898,7 @@ static void tx_intr_handler(struct fifo_
>  
>  			/* update t_code statistics */
>  			err >>= 48;
> -			switch(err) {
> +			switch((int)err) {

Hm, maybe add a comment, too?
This cast looks redundant at the first look and someone
who doesn't understand it might submit a patch to remove it again.

>  				case 2:
>  					nic->mac_control.stats_info->sw_stat.
>  							tx_buf_abort_cnt++;
> @@ -6825,7 +6825,7 @@ static int rx_osm_handler(struct ring_in
>  			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
>  		}
>  		err >>= 48;
> -		switch(err) {
> +		switch((int)err) {
>  			case 1:
>  				sp->mac_control.stats_info->sw_stat.
>  				rx_parity_err_cnt++;
> 
> Andreas.
> 



-- 
Greetings Michael.
