From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Add /proc/net/tcp_listen
Date: Fri, 18 Jun 2004 12:01:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618.120115.21661713.yoshfuji@linux-ipv6.org>
References: <20040618043151.0483c158.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20040618043151.0483c158.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040618043151.0483c158.ak@suse.de> (at Fri, 18 Jun 2004 04:31:51 +0200), Andi Kleen <ak@suse.de> says:

>  int __init tcp4_proc_init(void)
>  {
> -	return tcp_proc_register(&tcp4_seq_afinfo);
> +	int err = tcp_proc_register(&tcp4_seq_afinfo);
> +	if (err) 
> +		return err;
> +	return tcp_proc_register(&tcp4_listen_seq_afinfo);
>  }
>  
>  void tcp4_proc_exit(void)
>  {
>  	tcp_proc_unregister(&tcp4_seq_afinfo);
> +	tcp_proc_unregister(&tcp4_listen_seq_afinfo);
>  }
>  #endif /* CONFIG_PROC_FS */
>  

If you register A then B, it is better to unregister B then A (symmetric).
Yes, it does not matter in this case, but it is better coding style
since there often are dependencies.

--yoshfuji
