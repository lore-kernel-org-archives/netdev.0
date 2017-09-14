From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Outreachy kernel] [PATCH] staging: irda: Remove typedef
 struct
Date: Thu, 14 Sep 2017 07:59:26 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709140759020.2091@hadrien>
References: <20170914045538.GA24121@Haneen>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Samuel Ortiz <samuel@sortiz.org>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 outreachy-kernel <outreachy-kernel@googlegroups.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Haneen Mohammed <hamohammed.sa@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170914045538.GA24121@Haneen>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On Wed, 13 Sep 2017, Haneen Mohammed wrote:

> This patch remove typedef from a structure with all its ocurrences
> since using typedefs for structures is discouraged.
> Issue found using Coccinelle:
>
> @r1@
> type T;
> @@
>
> typedef struct { ... } T;
>
> @script:python c1@
> T2;
> T << r1.T;
> @@
> if T[-2:] =="_t" or T[-2:] == "_T":
> 	coccinelle.T2 = T[:-2];
> else:
> 	coccinelle.T2 = T;
>
> print T, coccinelle.T2
>
> @r2@
> type r1.T;
> identifier c1.T2;
> @@
> -typedef
> struct
> + T2
> { ... }
> -T
> ;
>
> @r3@
> type r1.T;
> identifier c1.T2;
> @@
> -T
> +struct T2
>
> Signed-off-by: Haneen Mohammed <hamohammed.sa@gmail.com>

Acked-by: Julia Lawall <julia.lawall@lip6.fr>

> ---
>  drivers/staging/irda/include/net/irda/qos.h | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/staging/irda/include/net/irda/qos.h b/drivers/staging/irda/include/net/irda/qos.h
> index 05a5a24..a0315b5 100644
> --- a/drivers/staging/irda/include/net/irda/qos.h
> +++ b/drivers/staging/irda/include/net/irda/qos.h
> @@ -58,23 +58,23 @@
>  #define IR_16000000 0x02
>
>  /* Quality of Service information */
> -typedef struct {
> +struct qos_value {
>  	__u32 value;
>  	__u16 bits; /* LSB is first byte, MSB is second byte */
> -} qos_value_t;
> +};
>
>  struct qos_info {
>  	magic_t magic;
>
> -	qos_value_t baud_rate;       /* IR_11520O | ... */
> -	qos_value_t max_turn_time;
> -	qos_value_t data_size;
> -	qos_value_t window_size;
> -	qos_value_t additional_bofs;
> -	qos_value_t min_turn_time;
> -	qos_value_t link_disc_time;
> +	struct qos_value baud_rate;       /* IR_11520O | ... */
> +	struct qos_value max_turn_time;
> +	struct qos_value data_size;
> +	struct qos_value window_size;
> +	struct qos_value additional_bofs;
> +	struct qos_value min_turn_time;
> +	struct qos_value link_disc_time;
>
> -	qos_value_t power;
> +	struct qos_value power;
>  };
>
>  extern int sysctl_max_baud_rate;
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe@googlegroups.com.
> To post to this group, send email to outreachy-kernel@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/20170914045538.GA24121%40Haneen.
> For more options, visit https://groups.google.com/d/optout.
>
