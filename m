From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net-next: make sock diag per-namespace
Date: Mon, 16 Jul 2012 15:00:59 +0100
Message-ID: <1342447259.2523.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342440849-1757320-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Andrew Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342440849-1757320-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-07-16 at 16:14 +0400, Andrew Vagin wrote:
> Before this patch sock_diag works for init_net only and dumps
> information about sockets from all namespaces.
> 
> This patch expands sock_diag for all name-spaces.
> It creates a netlink kernel socket for each netns and filters
> data during dumping.
[...]
> --- a/net/core/sock_diag.c
> +++ b/net/core/sock_diag.c
> @@ -166,23 +166,39 @@ static void sock_diag_rcv(struct sk_buff *skb)
>  	mutex_unlock(&sock_diag_mutex);
>  }
>  
> -struct sock *sock_diag_nlsk;
> -EXPORT_SYMBOL_GPL(sock_diag_nlsk);
> +struct sock *diag_nlsk;
> +EXPORT_SYMBOL_GPL(diag_nlsk);
[...]

This new variable seems to be unused.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
