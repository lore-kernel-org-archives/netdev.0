From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sat, 30 Jun 2007 08:13:02 -0400
Message-ID: <20070630081302.66b1d984@oldman>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, power-072X8lT/F9NAfugRpC6u6w@public.gmane.org, zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?B?IlTDtnLDtms=?=.Edvin"
	<edwintorok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>"@smtp2.linux-foundation.org
Return-path: <power-bounces-072X8lT/F9NAfugRpC6u6w@public.gmane.org>
In-Reply-To: <4354d3270706300447ladcda4by987b1f87963112f9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://www.bughost.org/mailman/listinfo/power>,
	<mailto:power-request-072X8lT/F9NAfugRpC6u6w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.bughost.org/pipermail/power>
List-Post: <mailto:power-072X8lT/F9NAfugRpC6u6w@public.gmane.org>
List-Help: <mailto:power-request-072X8lT/F9NAfugRpC6u6w@public.gmane.org?subject=help>
List-Subscribe: <http://www.bughost.org/mailman/listinfo/power>,
	<mailto:power-request-072X8lT/F9NAfugRpC6u6w@public.gmane.org?subject=subscribe>
Sender: power-bounces-072X8lT/F9NAfugRpC6u6w@public.gmane.org
Errors-To: power-bounces-072X8lT/F9NAfugRpC6u6w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Jun 2007 14:47:35 +0300
"T=C3=B6r=C3=B6k Edvin" <edwintorok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> When the interface is down (or driver removed), the BroadCom 44xx card =
remains
> powered on, and both its MAC and PHY is using up power.
> This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the interfa=
ce
> is halted, and does a partial chip reset turns off the activity LEDs to=
o.
>=20
> Applies to 2.6.22-rc6, or current git head.
>=20
> Tested on a Broadcom BCM4401-B0 card, it saves ~0.5W (measured using po=
wertop).
>=20
> Signed-off-by: Torok Edwin <edwintorok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  b44.c |   25 ++++++++++++++++++++-----
>   1 file changed, 20 insertions(+), 5 deletions(-)
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 879a2ff..00d0f57 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -113,6 +113,8 @@ static void b44_init_rings(struct b44 *);
>  #define B44_FULL_RESET		1
>  #define B44_FULL_RESET_SKIP_PHY	2
>  #define B44_PARTIAL_RESET	3
> +#define B44_CHIP_RESET_FULL     4
> +#define B44_CHIP_RESET_PARTIAL  5
>=20
>  static void b44_init_hw(struct b44 *, int);
>=20
> @@ -1283,7 +1285,7 @@ static void b44_clear_stats(struct b44 *bp)
>  }
>=20
>  /* bp->lock is held. */
> -static void b44_chip_reset(struct b44 *bp)
> +static void b44_chip_reset(struct b44 *bp, int reset_kind)
>  {
>  	if (ssb_is_core_up(bp)) {
>  		bw32(bp, B44_RCV_LAZY, 0);
> @@ -1307,6 +1309,10 @@ static void b44_chip_reset(struct b44 *bp)
>=20
>  	b44_clear_stats(bp);
>=20
> +	if (reset_kind =3D=3D B44_CHIP_RESET_PARTIAL)
> +		return;/* don't enable PHY if we are doing a partial reset
> +		, we are probably going to power down */
> +

This is a non-standard formatting for comments, please follow
Coding style:


Linux style for comments is the C89 "/* ... */" style.
Don't use C99-style "// ..." comments.

The preferred style for long (multi-line) comments is:

	/*
	 * This is the preferred style for multi-line
	 * comments in the Linux kernel source code.
	 * Please use it consistently.
	 *
	 * Description:  A column of asterisks on the left side,
	 * with beginning and ending almost-blank lines.
	 */
