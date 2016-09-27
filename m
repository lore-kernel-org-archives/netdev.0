From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v5 1/7] ipv6 addrconf: enable use of proc_dointvec_minmax
 in addrconf_sysctl
Date: Tue, 27 Sep 2016 19:16:04 +0900
Message-ID: <c165e18e-9888-e7cd-deb2-2ccfb1318039@miraclelinux.com>
References: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
 <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
 <1474969963-17402-2-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36485 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbcI0KQJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:16:09 -0400
Received: by mail-pa0-f46.google.com with SMTP id qn7so4259493pac.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 03:16:09 -0700 (PDT)
In-Reply-To: <1474969963-17402-2-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Maciej Żenczykowski wrote:
> From: Maciej Żenczykowski <maze@google.com>
> 
> Signed-off-by: Maciej Żenczykowski <maze@google.com>
> ---
>  net/ipv6/addrconf.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2f1f5d439788..11fa1a5564d4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -6044,8 +6044,14 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
>  
>  	for (i = 0; table[i].data; i++) {
>  		table[i].data += (char *)p - (char *)&ipv6_devconf;
> -		table[i].extra1 = idev; /* embedded; no ref */
> -		table[i].extra2 = net;
> +		/* If one of these is already set, then it is not safe to
> +		 * overwrite either of them: this makes proc_dointvec_minmax
> +		 * usable.
> +		 */
> +		if (!table[i].extra1 && !table[i].extra2) {
> +			table[i].extra1 = idev; /* embedded; no ref */
> +			table[i].extra2 = net;
> +		}
>  	}
>  
>  	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
> 

This seems nothing to do with the RFC7559 changes.
Why don't you submit this as a separate patch?

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
