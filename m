From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch 2/2] rocker: silence shift wrapping warning
Date: Wed, 25 Feb 2015 05:50:15 -0800
Message-ID: <CAE4R7bC6qrjDHNvKVCSPqxTo6LwCU2qm76yS8mYtsfC3nYQRag@mail.gmail.com>
References: <20150225133612.GV19745@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150225133612.GV19745@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 5:36 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> "val" is declared as a u64 so static checkers complain that this shift
> can wrap.  I don't have the hardware but probably it's doesn't have over
> 31 ports.  Still we may as well silence the warning even if it's not a
> real bug.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 713a13c..9fb6948 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -1257,9 +1257,9 @@ static void rocker_port_set_enable(struct rocker_port *rocker_port, bool enable)
>         u64 val = rocker_read64(rocker_port->rocker, PORT_PHYS_ENABLE);
>
>         if (enable)
> -               val |= 1 << rocker_port->lport;
> +               val |= 1ULL << rocker_port->lport;
>         else
> -               val &= ~(1 << rocker_port->lport);
> +               val &= ~(1ULL << rocker_port->lport);
>         rocker_write64(rocker_port->rocker, PORT_PHYS_ENABLE, val);
>  }
>

Acked-by: Scott Feldman <sfeldma@gmail.com>
