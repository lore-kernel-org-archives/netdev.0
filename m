From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ip_tunnel: Move stats update to iptunnel_xmit()
Date: Wed, 23 Dec 2015 10:49:07 +0100
Message-ID: <567A6E13.3080909@6wind.com>
References: <1450744476-23539-1-git-send-email-pshelar@nicira.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33262 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbbLWJtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 04:49:10 -0500
Received: by mail-wm0-f42.google.com with SMTP id p187so138109066wmp.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 01:49:10 -0800 (PST)
In-Reply-To: <1450744476-23539-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/12/2015 01:34, Pravin B Shelar a =C3=A9crit :
> By moving stats update into iptunnel_xmit(), we can simplify
> iptunnel_xmit() usage. With this change there is no need to
> call another function (iptunnel_xmit_stats()) to update stats
> in tunnel xmit code path.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
[snip]
> +static inline void iptunnel_xmit_stats(struct net_device *dev, int e=
rr)
>   {
>   	if (err > 0) {
> -		struct pcpu_sw_netstats *tstats =3D get_cpu_ptr(stats);
> +		struct pcpu_sw_netstats *tstats =3D get_cpu_ptr(dev->tstats);
>
>   		u64_stats_update_begin(&tstats->syncp);
>   		tstats->tx_bytes +=3D err;
>   		tstats->tx_packets++;
>   		u64_stats_update_end(&tstats->syncp);
>   		put_cpu_ptr(tstats);
> -	} else if (err < 0) {
> +	} else {
> +		struct net_device_stats *err_stats =3D &dev->stats;
> +
>   		err_stats->tx_errors++;
>   		err_stats->tx_aborted_errors++;
> -	} else {
> -		err_stats->tx_dropped++;
>   	}
>   }
Why do you remove the case 'err =3D=3D 0'?
At least, it needs an explanation in the commit log.
