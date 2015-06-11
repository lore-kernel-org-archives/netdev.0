From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH net-next v2] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Thu, 11 Jun 2015 10:15:16 -0700
Message-ID: <CAMUH3-WfUghz=yGcRBemz=we23w=cBK8R=7S=d9Xy6mjELKrAg@mail.gmail.com>
References: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:33872 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbbFKRPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 13:15:37 -0400
Received: by yhid80 with SMTP id d80so4800257yhi.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 10:15:37 -0700 (PDT)
In-Reply-To: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 8:19 AM,  <sfeldma@gmail.com> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Fix a BUG_ON() where CONFIG_NET_SWITCHDEV is set but the driver for a
> bridged port does not support switchdev_port_attr_set op.  Don't BUG_ON()
> if -EOPNOTSUPP is returned.
>
> Also change BUG_ON() to netdev_err since this is a normal error path and
> does not warrant the use of BUG_ON(), which is reserved for unrecoverable
> errs.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  net/switchdev/switchdev.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index e008057..ecd1b3f 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -103,7 +103,9 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
>
>         rtnl_lock();
>         err = switchdev_port_attr_set(asw->dev, &asw->attr);
> -       BUG_ON(err);
> +       if (err && err != -EOPNOTSUPP)
> +               netdev_err(asw->dev, "failed (err=%d) to set attribute (id=%d)\n",
> +                          err, asw->attr.id);
>         rtnl_unlock();
>
>         dev_put(asw->dev);
> --
> 1.7.10.4
>

I just tried this patch against the original test case, and this one
works well for me. Thanks!
