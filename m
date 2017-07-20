From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in balance-alb mode
Date: Thu, 20 Jul 2017 10:07:44 -0400
Message-ID: <CAHashqBi4Jz6r9X0Oa-Q4kJtEQpjSR+_AczDWhCi3FXpkBdMJQ@mail.gmail.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A0296FEF5@BPXM09GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A0296FEF5@BPXM09GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2017 at 1:20 AM, Kosuke Tatsukawa <tatsu@ab.jp.nec.com> wrote:
> balance-alb mode used to have transmit dynamic load balancing feature
> enabled by default.  However, transmit dynamic load balancing no longer
> works in balance-alb after commit 8b426dc54cf4 ("bonding: remove
> hardcoded value").
>
> Both balance-tlb and balance-alb use the function bond_do_alb_xmit() to
> send packets.  This function uses the parameter tlb_dynamic_lb.
> tlb_dynamic_lb used to have the default value of 1 for balance-alb, but
> now the value is set to 0 except in balance-tlb.
>
> Re-enable transmit dyanmic load balancing by initializing tlb_dynamic_lb
> for balance-alb similar to balance-tlb.
>
> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
> Cc: stable@vger.kernel.org

You probably should add:

Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value").

Otherwise this looks reasonable to me.

Acked-by: Andy Gospodarek <andy@greyhouse.net>


> ---
>  drivers/net/bonding/bond_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 14ff622..181839d 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4596,7 +4596,7 @@ static int bond_check_params(struct bond_params *params)
>         }
>         ad_user_port_key = valptr->value;
>
> -       if (bond_mode == BOND_MODE_TLB) {
> +       if ((bond_mode == BOND_MODE_TLB) || (bond_mode == BOND_MODE_ALB)) {
>                 bond_opt_initstr(&newval, "default");
>                 valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB),
>                                         &newval);
>
