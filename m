From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] BIC tcp congestion calculation timestamp
Date: Thu, 29 Jul 2004 16:01:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729160114.050adaae.davem@redhat.com>
References: <20040729112934.32002c24@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040729112934.32002c24@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 29 Jul 2004 11:29:34 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> +		__u32   last_stamp;     /* time when updated last_cwnd */
 ...
> +static void init_bictcp(struct tcp_opt *tp)
> +{
> +	tp->bictcp.cnt = 0;
> +
> +	tp->bictcp.last_max_cwnd = 0;
> +	tp->bictcp.last_cwnd = 0;
> +	tp->bictcp.last_stamp = 0;
> +}
 ...
> +	if (tp->bictcp.last_cwnd == tp->snd_cwnd &&
> +	   (s32)(tcp_time_stamp - tp->bictcp.last_stamp) <= (HZ>>5))
> +		return tp->bictcp.cnt;

What if tcp_time_stamp is zero the first time this code runs
after init_bictcp()?

Maybe a better initialization value in init_bictcp() would
be "tcp_time_stamp - ((HZ >> 5) + 1)"?
