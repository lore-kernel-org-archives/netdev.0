From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] net/hamradio/dmascc: remove inlines
Date: Sat, 10 Jul 2004 13:00:55 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <40F020C7.5010608@pobox.com>
References: <20040710010414.GX28324@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20040710010414.GX28324@fs.tum.de>
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Trying to compile drivers/scsi/ips.c with gcc 3.4 and
>   # define inline         __inline__ __attribute__((always_inline))
> results in compile errors starting with the following:
> 
> <--  snip  -->
> 
> ...
>   CC      drivers/net/hamradio/dmascc.o
> drivers/net/hamradio/dmascc.c: In function `scc_isr':
> drivers/net/hamradio/dmascc.c:250: sorry, unimplemented: inlining failed 
> in call to 'z8530_isr': function body not available
> drivers/net/hamradio/dmascc.c:969: sorry, unimplemented: called from here
> drivers/net/hamradio/dmascc.c:250: sorry, unimplemented: inlining failed 
> in call to 'z8530_isr': function body not available
> drivers/net/hamradio/dmascc.c:978: sorry, unimplemented: called from here
> make[3]: *** [drivers/net/hamradio/dmascc.o] Error 1
> 
> <--  snip  -->
> 
> 
> The patch below removes all inlines from dmascc.c .
> 
> 
> diffstat output:
>  drivers/net/hamradio/dmascc.c |   20 ++++++++++----------
>  1 files changed, 10 insertions(+), 10 deletions(-)
> 
> 
> Signed-off-by: Adrian Bunk <bunk@fs.tum.de>
> 
> --- linux-2.6.7-mm7-full-gcc3.4/drivers/net/hamradio/dmascc.c.old	2004-07-10 02:51:07.000000000 +0200
> +++ linux-2.6.7-mm7-full-gcc3.4/drivers/net/hamradio/dmascc.c	2004-07-10 03:00:43.000000000 +0200
> @@ -247,7 +247,7 @@
>  static int scc_set_mac_address(struct net_device *dev, void *sa);
>  
>  static irqreturn_t scc_isr(int irq, void *dev_id, struct pt_regs * regs);
> -static inline void z8530_isr(struct scc_info *info);
> +static void z8530_isr(struct scc_info *info);
>  static void rx_isr(struct scc_priv *priv);
>  static void special_condition(struct scc_priv *priv, int rc);
>  static void rx_bh(void *arg);
> @@ -255,11 +255,11 @@
>  static void es_isr(struct scc_priv *priv);
>  static void tm_isr(struct scc_priv *priv);
>  
> -static inline void tx_on(struct scc_priv *priv);
> -static inline void rx_on(struct scc_priv *priv);
> -static inline void rx_off(struct scc_priv *priv);
> +static void tx_on(struct scc_priv *priv);
> +static void rx_on(struct scc_priv *priv);
> +static void rx_off(struct scc_priv *priv);
>  static void start_timer(struct scc_priv *priv, int t, int r15);
> -static inline unsigned char random(void);
> +static unsigned char random(void);
>  
>  
>  /* Initialization variables */
> @@ -981,7 +981,7 @@
>  }
>  
>  
> -static inline void z8530_isr(struct scc_info *info) {
> +static void z8530_isr(struct scc_info *info) {
>    int is, i = 100;
>  
>    while ((is = read_scc(&info->priv[0], R3)) && i--) {
> @@ -1294,7 +1294,7 @@
>  }
>  
>  
> -static inline void tx_on(struct scc_priv *priv) {
> +static void tx_on(struct scc_priv *priv) {
>    int i, n;
>    unsigned long flags;
>  
> @@ -1330,7 +1330,7 @@
>  }
>  
>  
> -static inline void rx_on(struct scc_priv *priv) {
> +static void rx_on(struct scc_priv *priv) {
>    unsigned long flags;
>  
>    /* Clear RX FIFO */
> @@ -1364,7 +1364,7 @@
>  }
>  
>  
> -static inline void rx_off(struct scc_priv *priv) {
> +static void rx_off(struct scc_priv *priv) {
>    /* Disable receiver */
>    write_scc(priv, R3, Rx8);
>    /* Disable DREQ / RX interrupt */
> @@ -1397,7 +1397,7 @@
>  }
>  
>  
> -static inline unsigned char random(void) {
> +static unsigned char random(void) {
>    /* See "Numerical Recipes in C", second edition, p. 284 */
>    rand = rand * 1664525L + 1013904223L;
>    return (unsigned char) (rand >> 24);




It seems like you are going directly against the intent of the author, 
with this patch.

	Jeff


