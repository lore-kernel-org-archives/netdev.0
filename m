From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 07:25:42 +0200
Message-ID: <20080328052543.M60286@visp.net.lb>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, dada1@cosmosbay.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080327.150308.205829519.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just to make sure 2.6.24.3 is stable and it is regression i am supplying 
output from it.
Do you want me to submit summary to bugzilla and regression list as well?

And in short, IMHO 2.6.25 have major issues on routing that have to be fixed 
before release. TRIE is crashing, and even with HASH there is leak. I am 
trying my best to bisect it, but it is major router and i cannot take much 
risk on it, so i wish i can simulate in my home mini-lab. Still i am not able 
to get even proper switch (Lebanon difficult country for IT).

Kup ~ # uname -a
Linux Kup 2.6.24.3-build-0023 #3 SMP Sat Mar 8 13:01:35 EET 2008 i686 unknown

up ~ # rtstat -i60 -c6000
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
   54750|    4430|    1128|       0|      12|       0|       0|       0|     
263|     190|       0|     709|     708|       0|       0|    3545|     313|
   92913|    8829|    1211|       0|       1|       0|       0|       0|     
343|     163|       0|    1375|    1373|       0|       0|   12545|     724|
  115323|    8232|     906|       0|       0|       0|       0|       0|     
299|     128|       0|    1035|    1033|       0|       0|   18069|     813|
  128985|    8650|     839|       0|       0|       0|       0|       0|     
289|     115|       0|     954|     952|       0|       0|   22515|     845|
  116682|    8911|     861|       0|       0|       0|       0|       0|     
288|     117|       0|     978|     976|       0|       0|   23433|     775|
   99969|    9164|     889|       0|       0|       0|       0|       0|     
280|     113|       0|    1002|    1000|       0|       0|   26741|     839|
  124602|    9395|    1012|       0|       0|       0|       0|       0|     
271|     122|       0|    1134|    1132|       0|       0|   27381|     787|
  110051|   10036|     824|       0|       0|       0|       0|       0|     
279|     120|       0|     944|     942|       0|       0|   28558|     783|
  126835|   10631|     772|       0|       0|       0|       0|       0|     
274|     117|       0|     888|     886|       0|       0|   29451|     780|
  111881|   10357|     762|       0|       0|       0|       0|       0|     
275|     117|       0|     879|     877|       0|       0|   28235|     751|
  127018|   10178|     796|       0|       0|       0|       0|       0|     
283|     117|       0|     913|     911|       0|       0|   29480|     807|
  112242|    9839|     814|       0|       0|       0|       0|       0|     
293|     115|       0|     929|     927|       0|       0|   28095|     796|
   41267|    9493|    1217|       0|       1|       0|       0|       0|     
269|     138|       0|     811|     810|       0|       0|   18545|     548|
   76380|    9722|    1060|       0|       1|       0|       0|       0|     
250|     135|       0|    1195|    1193|       0|       0|   14786|     414|
   99922|    9811|     779|       0|       0|       0|       0|       0|     
281|     124|       0|     902|     900|       0|       0|   21853|     589|

Kup ~ # rtstat -i60 -c6000
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|

  122053|  150955|   14888|       0|      25|       1|       0|       0|    
4611|    2090|       0|   15820|   15789|       0|       0|  369513|   11562|
  105226|   10215|     872|       0|       0|       0|       0|       0|     
279|     116|       0|     988|     986|       0|       0|   30343|     799|
  126236|   10462|     924|       0|       0|       0|       0|       0|     
260|     120|       0|    1044|    1042|       0|       0|   31699|     782|
  114492|    9782|     884|       0|       0|       0|       0|       0|     
253|     120|       0|    1005|    1003|       0|       0|   29695|     722|

After ip route flush cache
Kup ~ # rtstat -i60 -c6000
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
    9088|  202136|   19262|       0|      29|       1|       0|       0|    
5976|    2696|       0|   20647|   20606|       0|       0|  521714|   15415|


!!!!!
I am not wrong, ip route flush cache doesn't work at 2.6.25-rc7. I will make 
sure about that now.


On Thu, 27 Mar 2008 15:03:08 -0700 (PDT), David Miller wrote
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 27 Mar 2008 19:56:09 +0100
> 
> > Maybe some netfilter problem ?
> > 
> > Please tell us more about your machine ;)
> 
> I'm beginning to suspect it's IFB and shaping somehow.
> 
> If those variables could be eliminated by eliminating them
> from the configuration, it would help diagnose this a lot.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

