From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] skfp: remove assignment expression in conditional (sparse)
Date: Fri, 15 Oct 2004 15:24:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41702405.6070100@pobox.com>
References: <4169BB68.7030206@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, mlindner@syskonnect.de
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <4169BB68.7030206@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> Fix sparse warning:
> drivers/net/skfp/hwmtm.c:1904:20: warning: assignment expression in
> conditional
> 
> 
> ------------------------------------------------------------------------
> 
> 
> Fix sparse warning:
> drivers/net/skfp/hwmtm.c:1904:20: warning: assignment expression in conditional
> 
> Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
> 
> diffstat:=
>  drivers/net/skfp/hwmtm.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff -Naurp ./drivers/net/skfp/hwmtm.c~skfp_expr ./drivers/net/skfp/hwmtm.c
> --- ./drivers/net/skfp/hwmtm.c~skfp_expr	2004-08-13 22:36:59.000000000 -0700
> +++ ./drivers/net/skfp/hwmtm.c	2004-10-10 15:15:21.090772760 -0700
> @@ -1901,7 +1901,7 @@ void smt_send_mbuf(struct s_smc *smc, SM
>  	}
>  
>  	if (!smc->hw.mac_ring_is_up || frag_count > queue->tx_free) {
> -		if (frame_status &= ~LAN_TX) {
> +		if ((frame_status &= ~LAN_TX) != 0) {


I would prefer to fix a 'assignment expression in conditional' warning 
by splitting the assignment and the test.

	Jeff
