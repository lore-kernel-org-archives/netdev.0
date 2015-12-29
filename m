From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Tue, 29 Dec 2015 15:37:39 +0100
Message-ID: <56829AB3.9000607@stressinduktion.org>
References: <20151228141435.GA13351@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com
To: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151228141435.GA13351@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28.12.2015 15:14, Willy Tarreau wrote:
> @@ -1528,10 +1546,8 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>   	if (!UNIXCB(skb).fp)
>   		return -ENOMEM;
>
> -	if (unix_sock_count) {
> -		for (i = scm->fp->count - 1; i >= 0; i--)
> -			unix_inflight(scm->fp->fp[i]);
> -	}
> +	for (i = scm->fp->count - 1; i >= 0; i--)
> +		unix_inflight(scm->fp->fp[i]);
>   	return max_level;

You seem to be able to remove the unix_sock_count variable altogether now.

Bye,
Hannes
