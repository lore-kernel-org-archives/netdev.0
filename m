From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/1] driver: tun: Forbid to set IFF_TUN and
 IFF_TAP at the same time
Date: Fri, 21 Oct 2016 13:50:12 +0300
Message-ID: <5c58ba54-9c37-0f4a-b68c-c15ed7008d3c@cogentembedded.com>
References: <1477030452-1765-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gfree.wind@gmail.com
To: fgao@ikuai8.com, davem@davemloft.net, jasowang@redhat.com,
        edumazet@google.com, pabeni@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33745 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754035AbcJUKuQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:50:16 -0400
Received: by mail-lf0-f50.google.com with SMTP id x79so144897129lff.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 03:50:15 -0700 (PDT)
In-Reply-To: <1477030452-1765-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/21/2016 9:14 AM, fgao@ikuai8.com wrote:

> From: Gao Feng <fgao@ikuai8.com>
>
> Current tun driver permits the ifr_flags is set with IFF_TUN and
> IFF_TAP at the same time. But actually there is only IFF_TUN flag
> works. And it does not make sense these two flags are set, so add
> this check.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/tun.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8093e39..c1f89c1 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1752,6 +1752,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		if (err < 0)
>  			return err;
>
> +		if ((ifr->ifr_flags & (IFF_TUN | IFF_TAP)) == (IFF_TUN | IFF_TAP)) {
> +			return -EINVAL;
> +		}

    {} not needed here.

MBR, Sergei
