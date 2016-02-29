From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v2 2/3] net: ipv4: tcp_probe: Replace timespec with
 timespec64
Date: Mon, 29 Feb 2016 13:27:17 +0900
Message-ID: <56D3C8A5.5090507@miraclelinux.com>
References: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
 <1456561938-7653-3-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, arnd@arndb.de,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>, netdev@vger.kernel.org,
	y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35256 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbcB2E1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 23:27:22 -0500
Received: by mail-pa0-f41.google.com with SMTP id bj10so15383173pad.2
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 20:27:21 -0800 (PST)
In-Reply-To: <1456561938-7653-3-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Deepa Dinamani wrote:
> TCP probe log timestamps use struct timespec which is
> not y2038 safe. Even though timespec might be good enough here
> as it is used to represent delta time, the plan is to get rid
> of all uses of timespec in the kernel.
> Replace with struct timespec64 which is y2038 safe.
> 
> Prints still use unsigned long format and type.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
>  net/ipv4/tcp_probe.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> index ebf5ff5..f6c50af 100644
> --- a/net/ipv4/tcp_probe.c
> +++ b/net/ipv4/tcp_probe.c
> @@ -187,13 +187,13 @@ static int tcpprobe_sprint(char *tbuf, int n)
>  {
>  	const struct tcp_log *p
>  		= tcp_probe.log + tcp_probe.tail;
> -	struct timespec tv
> -		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
> +	struct timespec64 ts
> +		= ktime_to_timespec64(ktime_sub(p->tstamp, tcp_probe.start));
>  
>  	return scnprintf(tbuf, n,
>  			"%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u %u\n",
> -			(unsigned long)tv.tv_sec,
> -			(unsigned long)tv.tv_nsec,
> +			(unsigned long)ts.tv_sec,
> +			(unsigned long)ts.tv_nsec,
>  			&p->src, &p->dst, p->length, p->snd_nxt, p->snd_una,
>  			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt, p->rcv_wnd);
>  }
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
