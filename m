From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] Per socket value for max datagram queue length
Date: Wed, 22 Jan 2014 16:32:08 +0100
Message-ID: <52DFE478.5030202@redhat.com>
References: <13e8aad86903481261581de7c29444e3@mindstab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennart Poettering <lennart@poettering.net>, kay.sievers@vrfy.org,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizefan@huawei.com>, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Dan Ballard <dan@mindstab.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <13e8aad86903481261581de7c29444e3@mindstab.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/22/2014 04:11 PM, Dan Ballard wrote:
> Provides a new option for setsockopt SO_MAX_DGRAM_QLEN that sets and
> gets a socket specific max datagram queue length. Currently each socket
> has one but it's only ever initialized from
> /proc/sys/net/unix/max_dgram_qlen and then never adjustable later. Now
> each socket can have it individually tweaked during it's life.
>
> Signed-off-by: Dan Ballard <dan@mindstab.net>
> ---
>   include/uapi/asm-generic/socket.h |    2 ++
>   net/core/sock.c                   |    7 +++++++
>   2 files changed, 9 insertions(+)
>
> diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
> index 38f14d0..f8c3e6b 100644
> --- a/include/uapi/asm-generic/socket.h
> +++ b/include/uapi/asm-generic/socket.h
> @@ -80,4 +80,6 @@
>
>   #define SO_MAX_PACING_RATE     47
>
> +#define SO_MAX_DGRAM_QLEN      48
> +

This needs to be added in more than just asm-generic, e.g.
have a look at SO_MAX_PACING_RATE or SO_BPF_EXTENSIONS.

Also you might need to rebase to current net-next head and
maybe describe use cases more in-depth; next to what Hannes
just commented.

>   #endif /* __ASM_GENERIC_SOCKET_H */
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5393b4b..1ff69d1 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -915,6 +915,10 @@ set_rcvbuf:
>                                           sk->sk_max_pacing_rate);
>                  break;
>
> +       case SO_MAX_DGRAM_QLEN:
> +               sk->sk_max_ack_backlog = val;
> +               break;
> +
>          default:
>                  ret = -ENOPROTOOPT;
>                  break;
> @@ -1182,6 +1186,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>                  v.val = sk->sk_max_pacing_rate;
>                  break;
>
> +       case SO_MAX_DGRAM_QLEN:
> +               v.val = sk->sk_max_ack_backlog;
> +               break;
>          default:
>                  return -ENOPROTOOPT;
>          }
