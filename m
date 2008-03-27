From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 20:37:44 +0200
Message-ID: <20080327183745.M9944@visp.net.lb>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net> <47EB46BD.2080001@cosmosbay.com> <20080327144102.M65267@visp.net.lb> <47EBB4A3.4090102@cosmosbay.com> <20080327151520.M89250@visp.net.lb> <47EBC641.8040405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47EBC641.8040405@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is output from dmesg with patch you supplied.

Kup /config # rtstat -i60 -c60
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
  103266|   69986|   11574|       0|      54|       0|       0|       0|    
1982|     634|       0|   10984|   10980|       0|       0|  191808|    5254|
  124787|   45125|    6019|       0|      28|       0|       0|       0|     
807|     230|       0|    6277|    6274|       0|       0|  128922|    2518|
  120270|   45588|    6288|       0|      30|       0|       0|       0|     
883|     214|       0|    6532|    6529|       0|       0|  125651|    2743|
  122253|   46522|    6582|       0|      27|       0|       0|       0|     
897|     213|       0|    6822|    6819|       0|       0|  124927|    2761|

[  102.534363] dst_total: 120397 delayed: 12 work_perf: 0 expires: 27999 
elapsed: 1 us
[  130.530240] dst_total: 124277 delayed: 12 work_perf: 0 expires: 32998 
elapsed: 2 us
[  163.523240] dst_total: 110006 delayed: 12 work_perf: 0 expires: 39000 
elapsed: 1 us
[  202.519402] dst_total: 130453 delayed: 12 work_perf: 0 expires: 45998 
elapsed: 1 us
[  248.511220] dst_total: 110637 delayed: 12 work_perf: 0 expires: 52600 
elapsed: 2 us
[  301.102445] dst_total: 129366 delayed: 12 work_perf: 0 expires: 60696 
elapsed: 6 us

After while

Kup /config # rtstat -i300 -c60
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
  129138|   64166|    9864|       0|      46|       0|       0|       0|    
1334|     358|       0|   10012|   10008|       0|       0|  173006|    3985|
  130125|   43971|   10829|       0|      70|       0|       0|       0|     
907|     195|       0|   11093|   11090|       0|       0|  100601|    2848|
  144857|   32041|   22233|       0|     234|       0|       0|       0|     
738|     261|       0|   22727|   22724|       2|       0|   42769|     811|

[  687.740779] dst_total: 129365 delayed: 12 work_perf: 0 expires: 104999 
elapsed: 1 us
[  792.736043] dst_total: 127247 delayed: 101589 work_perf: 0 expires: 600 
elapsed: 11274 us
[  793.347127] dst_total: 122440 delayed: 101589 work_perf: 0 expires: 1600 
elapsed: 11150 us
[  794.957419] dst_total: 123780 delayed: 101589 work_perf: 0 expires: 3100 
elapsed: 10896 us
[  798.068614] dst_total: 121992 delayed: 101589 work_perf: 0 expires: 5655 
elapsed: 11561 us
[  803.734450] dst_total: 120552 delayed: 101589 work_perf: 0 expires: 7988 
elapsed: 12254 us
[  811.733227] dst_total: 121105 delayed: 101589 work_perf: 0 expires: 10988 
elapsed: 12209 us
[  822.733196] dst_total: 120142 delayed: 101589 work_perf: 0 expires: 13987 
elapsed: 12039 us
[  836.730637] dst_total: 120823 delayed: 101589 work_perf: 0 expires: 17987 
elapsed: 12448 us
[  854.726913] dst_total: 127478 delayed: 101589 work_perf: 0 expires: 22988 
elapsed: 11435 us
[  877.724827] dst_total: 127497 delayed: 101589 work_perf: 0 expires: 27987 
elapsed: 12833 us
[  905.719818] dst_total: 126693 delayed: 101589 work_perf: 0 expires: 32987 
elapsed: 12068 us
[  938.714595] dst_total: 130740 delayed: 101589 work_perf: 0 expires: 38988 
elapsed: 11970 us
[  977.707568] dst_total: 135449 delayed: 101589 work_perf: 0 expires: 45989 
elapsed: 11747 us
[ 1023.701554] dst_total: 141181 delayed: 101589 work_perf: 0 expires: 52988 
elapsed: 12653 us
[ 1076.694012] dst_total: 147895 delayed: 101588 work_perf: 1 expires: 59987 
elapsed: 12217 us
[ 1136.684805] dst_total: 154798 delayed: 101588 work_perf: 0 expires: 67987 
elapsed: 12026 us
[ 1204.673424] dst_total: 163376 delayed: 101588 work_perf: 0 expires: 76988 
elapsed: 11151 us

and after 30 minutes more

Kup /config # rtstat -i300 -c60
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
  194841|  176962|   77964|       0|     684|       1|       0|       0|    
3939|    1143|       0|   79531|   79516|       7|       0|  401258|    9455|
  223224|   28262|   26499|       0|     236|       0|       0|       0|     
661|     216|       0|   26951|   26947|       3|       0|   93059|    1946|
  248425|   28257|   26784|       0|     226|       0|       0|       0|     
678|     202|       0|   27211|   27208|       3|       0|  115593|    2412|
  272823|   28943|   26728|       0|     246|       0|       0|       0|     
695|     200|       0|   27174|   27171|       3|       0|  135256|    2942|
  295087|   28835|   26701|       0|     252|       0|       0|       0|     
687|     194|       0|   27146|   27143|       3|       0|  154269|    3312|


[ 2043.547879] dst_total: 242922 delayed: 101588 work_perf: 0 expires: 119987 
elapsed: 12519 us
[ 2163.529997] dst_total: 252951 delayed: 101588 work_perf: 0 expires: 119987 
elapsed: 13930 us
[ 2283.512215] dst_total: 262678 delayed: 101588 work_perf: 0 expires: 119986 
elapsed: 14330 us
[ 2403.508447] dst_total: 271930 delayed: 101588 work_perf: 0 expires: 119972 
elapsed: 15230 us
[ 2523.476844] dst_total: 288046 delayed: 101588 work_perf: 0 expires: 119985 
elapsed: 15018 us
[ 2643.456996] dst_total: 296475 delayed: 101588 work_perf: 0 expires: 119987 
elapsed: 13654 us
[ 2763.438267] dst_total: 305033 delayed: 101588 work_perf: 0 expires: 119987 
elapsed: 13137 us



On Thu, 27 Mar 2008 17:07:29 +0100, Eric Dumazet wrote
> Denys Fedoryshchenko a :
> > I did this tuning. Not sure what does mean rt_cache_entries, but seems 
they 
> > are still increasing.
> >
> > Kup /config #  rtstat -c1000 -i60
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
> > rt_cache|
> >  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
> > out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
> > out_hlis|
> >         |        |     tot|      mc|     ute|        |  an_dst|  
> > an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
> > _search|t_search|
> >   274234| 1590009|  271953|       0|    1809|       6|       0|       
0|   
> > 24551|    7365|       0|  279991|  279867|      24|       0| 5438630|   
89656|
> >   280535|   25463|   19956|       0|     187|       0|       0|       
0|     
> > 485|     263|       0|   20407|   20404|       3|       0|   12796|     
242|
> >   288072|   25367|   19830|       0|     163|       0|       0|       
0|     
> > 493|     256|       0|   20248|   20245|       3|       0|   17146|     
346|
> >   294943|   25689|   19807|       0|     154|       0|       0|       
0|     
> > 438|     250|       0|   20211|   20208|       3|       0|   21554|     
432|
> >   301118|   25287|   19645|       0|     170|       0|       0|       
0|     
> > 466|     236|       0|   20052|   20048|       3|       0|   25713|     
528|
> >   307651|   25663|   20264|       0|     180|       0|       0|       
0|     
> > 472|     234|       0|   20678|   20675|       3|       0|   30588|     
607|
> >   313767|   25810|   20014|       0|     175|       0|       0|       
0|     
> > 459|     237|       0|   20425|   20422|       3|       0|   33701|     
699|
> >
> >
> >   
> Then try to lower gc_elasticity, to 3, or even 2
> 
> echo 3 >/proc/sys/net/ipv4/route/gc_elasticity


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

