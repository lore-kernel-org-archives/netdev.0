From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] Per socket value for max datagram queue length
Date: Wed, 22 Jan 2014 16:20:36 +0100
Message-ID: <20140122152036.GB7269@order.stressinduktion.org>
References: <13e8aad86903481261581de7c29444e3@mindstab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Lennart Poettering <lennart@poettering.net>, kay.sievers@vrfy.org,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizefan@huawei.com>, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dan Ballard <dan@mindstab.net>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <13e8aad86903481261581de7c29444e3@mindstab.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 22, 2014 at 07:11:20AM -0800, Dan Ballard wrote:
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5393b4b..1ff69d1 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -915,6 +915,10 @@ set_rcvbuf:
>                                          sk->sk_max_pacing_rate);
>                 break;
> 
> +       case SO_MAX_DGRAM_QLEN:
> +               sk->sk_max_ack_backlog = val;
> +               break;
> +

Shouldn't the backlog be capped for unprivileged users to some configurable
value? I even think that max_dgram_qlen should be the upper bound.

I guess it is not that serious as socket read accounting does account all
packets which sit in the backlog queue.

Greetings,

  Hannes
