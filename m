From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Problem with __check_and_rekey
Date: Tue, 12 Aug 2003 22:55:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812.225527.35784879.yoshfuji@linux-ipv6.org>
References: <20030812132050.GA27178@mochrul.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sasa@balabit.hu
In-Reply-To: <20030812132050.GA27178@mochrul.balabit>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030812132050.GA27178@mochrul.balabit> (at Tue, 12 Aug 2003 15:20:50 +0200), SZALAY Attila <sasa@balabit.hu> says:

> We created this patch to avoid the problem:
> 
> --- tcp_ipv4.c~ Tue Jun 24 22:44:52 2003
> +++ tcp_ipv4.c  Tue Aug 12 14:21:33 2003
> @@ -872,8 +872,10 @@
>                         tp->write_seq = ip_randomisn();
>                 else
>  #endif
> +               local_bh_disable();
>                 tp->write_seq = secure_tcp_sequence_number(sk->saddr, sk->daddr,
>                                                            sk->sport, usin->sin_port);
> +               local_bh_enable();
>         }
>  
>  #ifdef CONFIG_GRKERNSEC_RANDID
> 

You must forgot braces.
But anyway, I can't find these lines in linux-2.4.21 (or even in 2.6.x).
Are you sure you're working on the vanilla kernel?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
