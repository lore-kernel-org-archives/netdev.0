From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch 1/2] rocker: add a check for NULL in rocker_probe_ports()
Date: Wed, 25 Feb 2015 05:46:53 -0800
Message-ID: <CAE4R7bCVs-mnZi3gmde9ULu=XKv02Xye-X4QGYgnfYi3HO7HjA@mail.gmail.com>
References: <20150225133532.GU19745@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150225133532.GU19745@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 5:35 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Make sure kmalloc() succeeds.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 34389b6a..713a13c 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -4201,6 +4201,8 @@ static int rocker_probe_ports(struct rocker *rocker)
>
>         alloc_size = sizeof(struct rocker_port *) * rocker->port_count;
>         rocker->ports = kmalloc(alloc_size, GFP_KERNEL);
> +       if (!rocker->ports)
> +               return -ENOMEM;
>         for (i = 0; i < rocker->port_count; i++) {
>                 err = rocker_probe_port(rocker, i);
>                 if (err)

Acked-by: Scott Feldman <sfeldma@gmail.com>
