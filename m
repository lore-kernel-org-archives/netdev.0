From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH 38/62] s2io: Use static const
Date: Sun, 21 Nov 2010 23:36:22 -0600
Message-ID: <20101122053621.GA5754@exar.com>
References: <cover.1290305773.git.joe@perches.com>
 <c28022265d00c4220fc5ce4c74798ec5e8b3ea53.1290305776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:33066 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750768Ab0KVFgY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 00:36:24 -0500
Content-Disposition: inline
In-Reply-To: <c28022265d00c4220fc5ce4c74798ec5e8b3ea53.1290305776.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 20, 2010 at 06:38:39PM -0800, Joe Perches wrote:
> Using static const generally increases object text and decreases data size.
> It also generally decreases overall object size.
>
>    text          data     bss     dec     hex filename
>  109387           389   24432  134208   20c40 drivers/net/s2io.o.old
>  109358           389   24432  134179   20c23 drivers/net/s2io.o.new
>
> Signed-off-by: Joe Perches <joe@perches.com>

Looks fine to me.  Due to Dave's objections, I'll queue it in our tree
for the next s2io driver patch series.

Thanks,
Jon

> ---
>  drivers/net/s2io.c |   20 ++++++++++++--------
>  1 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 0f4219c..22fea37 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -3598,10 +3598,12 @@ static int s2io_set_swapper(struct s2io_nic *sp)
>       val64 = readq(&bar0->pif_rd_swapper_fb);
>       if (val64 != 0x0123456789ABCDEFULL) {
>               int i = 0;
> -             u64 value[] = { 0xC30000C3C30000C3ULL,   /* FE=1, SE=1 */
> -                             0x8100008181000081ULL,  /* FE=1, SE=0 */
> -                             0x4200004242000042ULL,  /* FE=0, SE=1 */
> -                             0};                     /* FE=0, SE=0 */
> +             static const u64 value[] = {
> +                     0xC30000C3C30000C3ULL,  /* FE=1, SE=1 */
> +                     0x8100008181000081ULL,  /* FE=1, SE=0 */
> +                     0x4200004242000042ULL,  /* FE=0, SE=1 */
> +                     0                       /* FE=0, SE=0 */
> +             };
>
>               while (i < 4) {
>                       writeq(value[i], &bar0->swapper_ctrl);
> @@ -3627,10 +3629,12 @@ static int s2io_set_swapper(struct s2io_nic *sp)
>
>       if (val64 != valt) {
>               int i = 0;
> -             u64 value[] = { 0x00C3C30000C3C300ULL,  /* FE=1, SE=1 */
> -                             0x0081810000818100ULL,  /* FE=1, SE=0 */
> -                             0x0042420000424200ULL,  /* FE=0, SE=1 */
> -                             0};                     /* FE=0, SE=0 */
> +             static const u64 value[] = {
> +                     0x00C3C30000C3C300ULL,  /* FE=1, SE=1 */
> +                     0x0081810000818100ULL,  /* FE=1, SE=0 */
> +                     0x0042420000424200ULL,  /* FE=0, SE=1 */
> +                     0                       /* FE=0, SE=0 */
> +             };
>
>               while (i < 4) {
>                       writeq((value[i] | valr), &bar0->swapper_ctrl);
> --
> 1.7.3.2.245.g03276.dirty
>

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
