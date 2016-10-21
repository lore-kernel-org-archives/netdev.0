From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/1] driver: tun: Forbid to set IFF_TUN and
 IFF_TAP at the same time
Date: Fri, 21 Oct 2016 04:28:07 -0700
Message-ID: <1477049287.7065.51.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477047735-26003-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jasowang@redhat.com, edumazet@google.com,
        pabeni@redhat.com, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35941 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754548AbcJUL2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:28:10 -0400
Received: by mail-pf0-f194.google.com with SMTP id r16so8426570pfg.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 04:28:09 -0700 (PDT)
In-Reply-To: <1477047735-26003-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-21 at 19:02 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Current tun driver permits the ifr_flags is set with IFF_TUN and
> IFF_TAP at the same time. But actually there is only IFF_TUN flag
> works. And it does not make sense these two flags are set, so add
> this check.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v2: Remove useless {}
>  v1: Initial patch
> 
>  drivers/net/tun.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8093e39..faaa189 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1752,6 +1752,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		if (err < 0)
>  			return err;
>  
> +		if ((ifr->ifr_flags & (IFF_TUN | IFF_TAP)) == (IFF_TUN | IFF_TAP))
> +			return -EINVAL;
> +
>  		/* Set dev type */
>  		if (ifr->ifr_flags & IFF_TUN) {
>  			/* TUN device */


This might break some applications.

It might be too late to add this check without a grace period.
