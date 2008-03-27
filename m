From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 15:52:19 +0100
Message-ID: <47EBB4A3.4090102@cosmosbay.com>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net> <47EB46BD.2080001@cosmosbay.com> <20080327144102.M65267@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080327144102.M65267@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Fedoryshchenko a =C3=A9crit :
> Yes, it seems related to routing. Before such thing was not happening=
 (maybe=20
> because TRIE was operating better?).
>
> Here is info at "peak time", i disable nmi_watchdog now, so garbage c=
ollector=20
> will not be triggered by nmi watchdog.=20
>
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|
> rt_cache|
>  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_mar=
ti|=20
> out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlis=
t|
> out_hlis|
>         |        |     tot|      mc|     ute|        |  an_dst| =20
> an_src|        |    _tot|     _mc|        |      ed|    miss| verflow=
|=20
> _search|t_search|
>   247011| 2255410|  162866|       0|     610|       5|       0|      =
 0|  =20
> 33761|    8574|       0|  165475|  165307|       0|       0|10407428|=
  174948|
>   251810|   43087|    2782|       0|       9|       0|       0|      =
 0|    =20
> 618|     122|       0|    2912|    2909|       0|       0|  241946|  =
  3796|
>   256277|   43035|    2739|       0|       9|       0|       0|      =
 0|    =20
> 595|     121|       0|    2867|    2864|       0|       0|  243724|  =
  3748|
>   260177|   43596|    2647|       0|       8|       0|       0|      =
 0|    =20
> 672|     123|       0|    2778|    2776|       0|       0|  246880|  =
  4048|
>   232741|   42270|    2759|       0|      15|       0|       0|      =
 0|    =20
> 665|     135|       0|    2910|    2907|       0|       0|  233990|  =
  3938|
>   226623|   42615|    2792|       0|      11|       0|       0|      =
 0|    =20
> 723|     132|       0|    2935|    2932|       0|       0|  218378|  =
  3862|
>   233190|   42397|    2778|       0|       8|       0|       0|      =
 0|    =20
> 675|     128|       0|    2913|    2909|       0|       0|  214258|  =
  3703|
>   239093|   42342|    2713|       0|       9|       0|       0|      =
 0|    =20
> 764|     126|       0|    2847|    2845|       0|       0|  216453|  =
  4080|
>   150539|   36992|    7564|       0|      58|       0|       0|      =
 0|    =20
> 539|     283|       0|    7902|    7900|       0|       0|   93459|  =
  1996|
>   154441|   40258|    4422|       0|      12|       0|       0|      =
 0|    =20
> 655|     212|       0|    4644|    4640|       0|       0|   77271|  =
  1458|
>
> On one "crash" i got=20
> Mar 27 11:27:15 205.177.186.74 [ 7141.156100] dst cache overflow
> Mar 27 11:27:15 205.177.186.74 [ 7141.002291] dst cache overflow
> Mar 27 11:27:15 205.177.186.74 [ 7141.162756] dst cache overflow
>
> So i increase now routes amount more than 512K to 5120K, and will see=
 more.
>  =20
You want to tune route cache for your special needs, and not permit it=20
to store 5 millions entries !

# default is a gc every 60 seconds, not good for large caches
echo 1 >/proc/sys/net/ipv4/route/gc_interval
# default is 8 entries per slot..
echo 4 >/proc/sys/net/ipv4/route/gc_elasticity
# avoid a flush every 10 minutes
echo 3600 >/proc/sys/net/ipv4/route/secret_interval




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
