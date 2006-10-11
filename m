From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 11 Oct 2006 10:59:03 +0900 (JST)
Message-ID: <20061011.105903.124167527.yoshfuji@linux-ipv6.org>
References: <4522A88E.2070200@redhat.com>
	<20061004.000722.99203823.davem@davemloft.net>
	<452C4D12.9060102@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, mgrondona@llnl.gov,
	behlendorf1@llnl.gov, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59407 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1030758AbWJKB4j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 21:56:39 -0400
To: woodard@redhat.com
In-Reply-To: <452C4D12.9060102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <452C4D12.9060102@redhat.com> (at Tue, 10 Oct 2006 18:46:58 -0700), Ben Woodard <woodard@redhat.com> says:

> diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
> --- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
> +++ linux-2.6.18.new/net/ipv4/tcp.c	2006-10-10 18:37:40.000000000 -0700
> @@ -1939,6 +1941,21 @@
>  		}
>  		break;
>  
> +        case TCP_BACKOFF_MAX:
> +                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
> +                        err = -EINVAL;
> +                else
> +                        tp->rto_max = val;
> +                break;
> + 
> +        case TCP_BACKOFF_INIT:
> +                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
> +                        err = -EINVAL;
> +                else
> +                        tp->rto_init = val;
> +                break;
> + 
> + 
>  	default:
>  		err = -ENOPROTOOPT;
>  		break;
> @@ -2110,6 +2127,12 @@
>  		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
>  			return -EFAULT;
>  		return 0;
> +        case TCP_BACKOFF_MAX:
> +	        val = tcp_rto_max(tp)*1000/HZ;
> +                break;
> +        case TCP_BACKOFF_INIT:
> +	        val = tcp_rto_init(tp)*1000/HZ;
> +                break;
>  	default:
>  		return -ENOPROTOOPT;
>  	};

They look very inconsistent.  Please use tp->rto_max / tp->rto_init.

--yoshfuji
