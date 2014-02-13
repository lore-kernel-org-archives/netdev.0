From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] net: remove useless if check from register_netdevice()
Date: Thu, 13 Feb 2014 08:23:08 -0800
Message-ID: <CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
References: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:38478 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbaBMQXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 11:23:09 -0500
Received: by mail-qc0-f171.google.com with SMTP id n7so18415660qcx.30
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 08:23:08 -0800 (PST)
In-Reply-To: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 8:47 PM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> remove useless if check from register_netdevice()
>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
> v1 -> v2: Fixed identation
> ---
>  net/core/dev.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4ad1b78..21a72ad 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
>         if (dev->netdev_ops->ndo_init) {
>                 ret = dev->netdev_ops->ndo_init(dev);
>                 if (ret) {
> -                       if (ret > 0)
> -                               ret = -EIO;
> +                       ret = -EIO;
>                         goto out;

why is it a useless check?
seems perfectly valid to me.
most of the time ndo_init() returns negative error code like -ENOMEM
which we want
to propagate further down and want to override it to -EIO if it's > 0
