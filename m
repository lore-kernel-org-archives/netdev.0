From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH net-next] af_unix: speedup /proc/net/unix
Date: Sat, 09 Jun 2012 09:42:07 +0400
Message-ID: <4FD2E22F.9090503@msgid.tls.msk.ru>
References: <1339167801.6001.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:53692 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572Ab2FIFmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 01:42:10 -0400
In-Reply-To: <1339167801.6001.111.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.06.2012 19:03, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> /proc/net/unix has quadratic behavior, and can hold unix_table_lock for
> a while if high number of unix sockets are alive. (90 ms for 200k
> sockets...)

Two comments, nitpicking...

[]
>  struct unix_iter_state {
>  	struct seq_net_private p;
> -	int i;
>  };

Can't seq_net_private be used directly?

> +static struct sock *unix_next_socket(struct seq_file *seq,
> +				     struct sock *sk,
> +				     loff_t *pos)
> +{
....
>  }
>  
>  static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  {
> +	return unix_next_socket(seq, v, pos);
>  }

Why unix_seq_next() is needed?  Can't unix_next_socket() be used directly instead?

Thanks,

/mjt
