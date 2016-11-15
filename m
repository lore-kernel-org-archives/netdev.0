From: Pavel Emelyanov <xemul@virtuozzo.com>
Subject: Re: [CRIU] [PATCH net-next] tcp: allow to enable the repair mode for
 non-listening sockets
Date: Tue, 15 Nov 2016 15:08:02 +0300
Message-ID: <582AFAA2.2000100@virtuozzo.com>
References: <1479176114-12658-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>, James Morris <jmorris@namei.org>,
        <linux-kernel@vger.kernel.org>, <criu@openvz.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Patrick McHardy <kaber@trash.net>
To: Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479176114-12658-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/2016 05:15 AM, Andrei Vagin wrote:
> The repair mode is used to get and restore sequence numbers and
> data from queues. It used to checkpoint/restore connections.
> 
> Currently the repair mode can be enabled for sockets in the established
> and closed states, but for other states we have to dump the same socket
> properties, so lets allow to enable repair mode for these sockets.
> 
> The repair mode reveals nothing more for sockets in other states.
> 
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> ---
>  net/ipv4/tcp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3251fe7..a2a3a8c 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2302,7 +2302,7 @@ EXPORT_SYMBOL(tcp_disconnect);
>  static inline bool tcp_can_repair_sock(const struct sock *sk)
>  {
>  	return ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN) &&
> -		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
> +		(sk->sk_state != TCP_LISTEN);
>  }
>  
>  static int tcp_repair_set_window(struct tcp_sock *tp, char __user *optbuf, int len)
> 
