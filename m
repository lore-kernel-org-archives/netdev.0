From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp_slow_start_after_idle
Date: Wed, 14 Jun 2006 09:46:58 -0700
Message-ID: <44903D82.40007@hp.com>
References: <20060613.223538.24611602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zach.brown@oracle.com, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:7114 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S932094AbWFNQq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 12:46:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060613.223538.24611602.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +tcp_slow_start_after_idle - BOOLEAN
> +	If set, provide RFC2861 behavior and time out the congestion
> +	window after an idle period.  An idle period is defined at
> +	the current RTO.  If unset, the congestion window will not
> +	be timed out after an idle period.
> +	Default: 1

Did you mean "defined as" rather than "defined at?"

Also, does the congestion window "time out" or does it decay?

Perhaps:

tcp_slow_start_after_idle - BOOLEAN
      If set, provide RFC2861 behavior and decay the congestion
      window after the connection has been idle for the connection's
      current RTO.  If unset, the congestion window will not decay
      when the connection has been idle.
      Default: 1

> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index de88c54..bfc71f9 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -227,6 +227,7 @@ extern int sysctl_tcp_abc;
>  extern int sysctl_tcp_mtu_probing;
>  extern int sysctl_tcp_base_mss;
>  extern int sysctl_tcp_workaround_signed_windows;
> +extern int sysctl_tcp_slow_start_after_idle;

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 743016b..be6d929 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -59,6 +59,9 @@ int sysctl_tcp_tso_win_divisor = 3;
>  int sysctl_tcp_mtu_probing = 0;
>  int sysctl_tcp_base_mss = 512;
>  
> +/* By default, RFC2861 behavior.  */
> +int sysctl_tcp_slow_start_after_idle = 1;
> +

Is this a candidate for "readmostly?"

rick jones
