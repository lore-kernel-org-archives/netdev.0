From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] jazzsonic: printk() style fixes
Date: Thu, 24 Oct 2013 19:54:41 -0200
Message-ID: <CAOMZO5B_Q7zHHkCunEe57Xtx7HuMxxAUSFFGYeoTO-DV-iu+jA@mail.gmail.com>
References: <1382650780-24114-1-git-send-email-tomster595@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tom D'Alba" <dalbat@rpi.edu>
To: "Tom D'Alba" <tomster595@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:50901 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab3JXVyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 17:54:41 -0400
Received: by mail-vb0-f43.google.com with SMTP id g10so1728816vbg.16
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 14:54:41 -0700 (PDT)
In-Reply-To: <1382650780-24114-1-git-send-email-tomster595@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Oct 24, 2013 at 7:39 PM, Tom D'Alba <tomster595@gmail.com> wrote:
> From: Tom D'Alba <dalbat@rpi.edu>
>
> Fixed printk() format by adding correct KERN_ statuses.
>
> Reviewed-by: Nicholas Guthrie <nickg4317@gmail.com>
> Reviewed-by: Sarah Williams <swilliams704@gmail.com>
> Reviewed-by: Jason Lee <calccrypto@gmail.com>
> Signed-off-by: Tom D'Alba <dalbat@rpi.edu>
> ---
>  drivers/net/ethernet/natsemi/jazzsonic.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
> index 79257f7..3a04d32 100644
> --- a/drivers/net/ethernet/natsemi/jazzsonic.c
> +++ b/drivers/net/ethernet/natsemi/jazzsonic.c
> @@ -135,7 +135,7 @@ static int sonic_probe1(struct net_device *dev)
>          */
>         silicon_revision = SONIC_READ(SONIC_SR);
>         if (sonic_debug > 1)
> -               printk("SONIC Silicon Revision = 0x%04x\n",silicon_revision);
> +         printk(KERN_INFO "SONIC Silicon Revision = 0x%04x\n",silicon_revision);

You could use netdev_info here instead.

>
>         i = 0;
>         while (known_revisions[i] != 0xffff &&
> @@ -143,13 +143,13 @@ static int sonic_probe1(struct net_device *dev)
>                 i++;
>
>         if (known_revisions[i] == 0xffff) {
> -               printk("SONIC ethernet controller not found (0x%4x)\n",
> +               printk(KERN_ERR "SONIC ethernet controller not found (0x%4x)\n",

You could use netdev_err here instead.

>                        silicon_revision);
>                 goto out;
>         }
>
>         if (sonic_debug  &&  version_printed++ == 0)
> -               printk(version);
> +             printk(KERN_INFO version);


You could use netdev_info here instead.
