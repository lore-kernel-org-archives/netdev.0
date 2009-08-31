From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH resend] drop_monitor: fix trace_napi_poll_hit()
Date: Mon, 31 Aug 2009 08:31:51 +0200
Message-ID: <4A9B6E57.7090703@gmail.com>
References: <4A9B6963.5090207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754506AbZHaGcH@vger.kernel.org>
In-Reply-To: <4A9B6963.5090207@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Xiao Guangrong a =C3=A9crit :
> The net_dev of backlog napi is NULL, like below:
>=20
> __get_cpu_var(softnet_data).backlog.dev =3D=3D NULL
>=20
> So, we should check it in napi tracepoint's probe function
>=20
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> ---
>  net/core/drop_monitor.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 9d66fa9..d311202 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -182,7 +182,8 @@ static void trace_napi_poll_hit(struct napi_struc=
t *napi)
>  	/*
>  	 * Ratelimit our check time to dm_hw_check_delta jiffies
>  	 */
> -	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> +	if (!napi->dev ||
> +	    !time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
>  		return;
> =20
>  	rcu_read_lock();


This reminds me dev->last_rx is not anymore updated, unless special con=
ditions
are met.

Test done in trace_napi_poll_hit() is probably not good, even with a no=
n null napi->dev
