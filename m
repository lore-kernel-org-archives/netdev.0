From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: delete unused req in tcp_synack_rtt_meas()
Date: Thu, 24 Oct 2013 08:46:22 -0700
Message-ID: <CAK6E8=fqxKrPyw=T08apDTmA47Hn1RUhztLSXHaAkw9wAOgwOw@mail.gmail.com>
References: <4fcb645d8f8f5d6dda0ebd1ce2bd0cc3bfb14311.1382607044.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4fcb645d8f8f5d6dda0ebd1ce2bd0cc3bfb14311.1382607044.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 24, 2013 at 2:31 AM, Weiping Pan <panweiping3@gmail.com> wrote:
> The parameter req is not used since
> 375fe02c9179(tcp: consolidate SYNACK RTT sampling)
Hi Weiping:

I just sent a bug-fix "tcp: fix SYNACK RTT estimation in Fast Open"
that will also take care of this redundant parameter. Thanks.
.
>
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---
>  net/ipv4/tcp_input.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a16b01b..ac8781a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2871,7 +2871,7 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
>  }
>
>  /* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
> -static void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
> +static void tcp_synack_rtt_meas(struct sock *sk)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
>         s32 seq_rtt = -1;
> @@ -5694,7 +5694,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>                 tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
>                 tp->snd_wnd = ntohs(th->window) << tp->rx_opt.snd_wscale;
>                 tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
> -               tcp_synack_rtt_meas(sk, req);
> +               tcp_synack_rtt_meas(sk);
>
>                 if (tp->rx_opt.tstamp_ok)
>                         tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
> --
> 1.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
