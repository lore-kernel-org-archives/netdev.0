From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 02:47:17 +0200
Message-ID: <20080328001648.M6781@visp.net.lb>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: dada1@cosmosbay.com, David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080327.150308.205829519.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


After removing shaping and ifb problem probably remains. I will try to apply 
mentioned by Denis Lunev, patch. 

Netfilter it is kind of difficult to remove completely, pattern of traffic 
will change a lot, and it will be false that it was cause of problem. I am 
using NOTRACK, SNAT, DNAT, sure filtering. Nothing "special".

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
  122438|25068014| 2464002|       0|    8579|     105|       0|       3|  
436160|  149272|       0| 2560231| 2557567|      54|       0|52890998| 
1164822|


[  355.594112] dst_total: 115387 delayed: 1 work_perf: 0 expires: 68196 
elapsed: 0 us
[  423.780775] dst_total: 126186 delayed: 1 work_perf: 0 expires: 76999 
elapsed: 0 us
[  500.768537] dst_total: 122085 delayed: 1 work_perf: 0 expires: 86000 
elapsed: 0 us
[  586.755462] dst_total: 121715 delayed: 1 work_perf: 0 expires: 95000 
elapsed: 1 us
[  681.741665] dst_total: 129798 delayed: 1 work_perf: 0 expires: 104999 
elapsed: 0 us
[  786.732216] dst_total: 116243 delayed: 74333 work_perf: 1 expires: 600 
elapsed: 7076 us
[  787.338620] dst_total: 116912 delayed: 74333 work_perf: 0 expires: 1600 
elapsed: 6962 us
[  788.945653] dst_total: 118565 delayed: 74333 work_perf: 0 expires: 3100 
elapsed: 7246 us
[  792.052890] dst_total: 121611 delayed: 74333 work_perf: 0 expires: 5672 
elapsed: 6954 us
[  797.730354] dst_total: 126794 delayed: 74333 work_perf: 0 expires: 7993 
elapsed: 7276 us
[  805.729136] dst_total: 115686 delayed: 74333 work_perf: 0 expires: 10993 
elapsed: 7270 us
[  816.727732] dst_total: 126402 delayed: 74333 work_perf: 0 expires: 13993 
elapsed: 7115 us
[  830.726662] dst_total: 121002 delayed: 74333 work_perf: 0 expires: 17992 
elapsed: 7179 us
[  848.724144] dst_total: 119849 delayed: 74333 work_perf: 0 expires: 22992 
elapsed: 7370 us
[  871.719176] dst_total: 124661 delayed: 74333 work_perf: 0 expires: 27993 
elapsed: 7313 us
[  899.715826] dst_total: 118860 delayed: 74333 work_perf: 0 expires: 32992 
elapsed: 7192 us
[  932.710299] dst_total: 120856 delayed: 74333 work_perf: 0 expires: 38993 
elapsed: 7291 us
[  971.704648] dst_total: 119519 delayed: 74333 work_perf: 0 expires: 45993 
elapsed: 6946 us
[ 1017.698036] dst_total: 126722 delayed: 74333 work_perf: 0 expires: 52992 
elapsed: 7300 us
[ 1070.693197] dst_total: 124835 delayed: 101547 work_perf: 3 expires: 600 
elapsed: 10089 us
[ 1071.303147] dst_total: 125939 delayed: 101547 work_perf: 0 expires: 1600 
elapsed: 9544 us
[ 1072.913253] dst_total: 128499 delayed: 101547 work_perf: 0 expires: 3100 
elapsed: 9895 us
[ 1076.021980] dst_total: 117827 delayed: 101547 work_perf: 0 expires: 5659 
elapsed: 10096 us
[ 1081.690082] dst_total: 127534 delayed: 101547 work_perf: 0 expires: 7990 
elapsed: 10052 us
[ 1089.690531] dst_total: 127330 delayed: 101547 work_perf: 0 expires: 10989 
elapsed: 11717 us


Without sysctl adjustments (each 1 minute)
Kup ~ # rtstat -i60 -c60
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
   40160|    3323|    1094|       0|      11|       0|       0|       0|     
282|     127|       0|     274|     274|       0|       0|    1867|     226|
  102698|   26174|    2885|       0|       6|       0|       0|       0|     
620|     228|       0|    3118|    3115|       0|       0|   37298|    1331|
  141996|   25752|    2172|       0|       3|       0|       0|       0|     
521|     167|       0|    2343|    2340|       0|       0|   66292|    1698|
  169128|   24716|    1593|       0|       2|       0|       0|       0|     
468|     140|       0|    1734|    1731|       0|       0|   83079|    1714|
  185495|   24867|    1493|       0|       1|       0|       0|       0|     
386|     125|       0|    1619|    1616|       0|       0|   97451|    1603|
  195665|   25227|    1443|       0|       1|       0|       0|       0|     
427|     126|       0|    1570|    1567|       0|       0|  111618|    1955|
  201357|   25239|    1370|       0|       2|       0|       0|       0|     
435|     118|       0|    1490|    1487|       0|       0|  119599|    2010|
  206841|   25805|    1487|       0|       2|       0|       0|       0|     
515|     120|       0|    1607|    1604|       0|       0|  123823|    2429|
  213800|   25230|    1678|       0|       2|       0|       0|       0|     
414|     116|       0|    1795|    1792|       0|       0|  127516|    2210|
  216461|   25882|    1503|       0|       2|       0|       0|       0|     
424|     114|       0|    1618|    1615|       0|       0|  136162|    2308|
  220386|   26141|    1632|       0|       2|       0|       0|       0|     
387|     115|       0|    1749|    1745|       0|       0|  137147|    2165|
  221533|   25649|    1476|       0|       2|       0|       0|       0|     
394|     116|       0|    1593|    1590|       0|       0|  131760|    2274|
  221139|   25682|    1368|       0|       2|       0|       0|       0|     
432|     111|       0|    1481|    1477|       0|       0|  130734|    2321|
  152901|   24897|    2242|       0|       6|       0|       0|       0|     
367|     157|       0|    2405|    2402|       0|       0|   68008|    1245|
  190000|   25295|    1747|       0|       1|       0|       0|       0|     
403|     143|       0|    1891|    1888|       0|       0|   69542|     916|


[  586.911061] dst_total: 225846 delayed: 4 work_perf: 0 expires: 95000 
elapsed: 1 us
[  681.897473] dst_total: 221226 delayed: 4 work_perf: 0 expires: 105000 
elapsed: 1 us
[  786.886616] dst_total: 145402 delayed: 59222 work_perf: 0 expires: 600 
elapsed: 5893 us
[  787.491390] dst_total: 145565 delayed: 59587 work_perf: 0 expires: 600 
elapsed: 5783 us
[  788.096098] dst_total: 145724 delayed: 59888 work_perf: 0 expires: 600 
elapsed: 5582 us
[  788.701111] dst_total: 145983 delayed: 60148 work_perf: 0 expires: 600 
elapsed: 5685 us
[  789.305991] dst_total: 146120 delayed: 60412 work_perf: 0 expires: 600 
elapsed: 5661 us
[  789.910802] dst_total: 146432 delayed: 60643 work_perf: 0 expires: 600 
elapsed: 5566 us
[  790.515868] dst_total: 146558 delayed: 61009 work_perf: 0 expires: 600 
elapsed: 5720 us
[  791.120788] dst_total: 146781 delayed: 61250 work_perf: 0 expires: 600 
elapsed: 5714 us
[  791.725773] dst_total: 147075 delayed: 61488 work_perf: 0 expires: 600 
elapsed: 5806 us
[  792.330558] dst_total: 147404 delayed: 61766 work_perf: 0 expires: 600 
elapsed: 5685 us
[  792.935548] dst_total: 147761 delayed: 61978 work_perf: 0 expires: 600 
elapsed: 5765 us
[  793.540664] dst_total: 147932 delayed: 62339 work_perf: 0 expires: 600 
elapsed: 5966 us
[  794.145640] dst_total: 148181 delayed: 62632 work_perf: 0 expires: 600 
elapsed: 6046 us
[  794.751394] dst_total: 148507 delayed: 62865 work_perf: 0 expires: 600 
elapsed: 5886 us
[  795.356327] dst_total: 148940 delayed: 63123 work_perf: 0 expires: 600 
elapsed: 5913 us
[  795.961312] dst_total: 149304 delayed: 63342 work_perf: 0 expires: 600 
elapsed: 5988 us
[  796.566230] dst_total: 149471 delayed: 63619 work_perf: 0 expires: 600 
elapsed: 6002 us
[  797.172182] dst_total: 149819 delayed: 63853 work_perf: 0 expires: 600 
elapsed: 6046 us
[  797.778163] dst_total: 150183 delayed: 64108 work_perf: 0 expires: 600 
elapsed: 6117 us
[  798.384008] dst_total: 150492 delayed: 64260 work_perf: 0 expires: 600 
elapsed: 6052 us
[  798.990028] dst_total: 150702 delayed: 64535 work_perf: 0 expires: 600 
elapsed: 6167 us
[  799.595797] dst_total: 151109 delayed: 64691 work_perf: 0 expires: 600 
elapsed: 6026 us
[  800.201763] dst_total: 151498 delayed: 64864 work_perf: 0 expires: 600 
elapsed: 6084 us
[  800.807742] dst_total: 151861 delayed: 65075 work_perf: 0 expires: 600 
elapsed: 6155 us
[  801.413577] dst_total: 152344 delayed: 65245 work_perf: 0 expires: 600 
elapsed: 6079 us
[  802.019727] dst_total: 152608 delayed: 65498 work_perf: 0 expires: 600 
elapsed: 6323 us
[  802.625410] dst_total: 153049 delayed: 65676 work_perf: 1 expires: 600 
elapsed: 6099 us
[  803.231251] dst_total: 153390 delayed: 65835 work_perf: 0 expires: 600 
elapsed: 6024 us
[  803.837186] dst_total: 153855 delayed: 65990 work_perf: 0 expires: 600 
elapsed: 6056 us
[  804.443457] dst_total: 154294 delayed: 66133 work_perf: 0 expires: 600 
elapsed: 6422 us
[  805.049167] dst_total: 154548 delayed: 66378 work_perf: 0 expires: 600 
elapsed: 6221 us
[  805.655036] dst_total: 155001 delayed: 66499 work_perf: 0 expires: 600 
elapsed: 6183 us
[  806.260986] dst_total: 155418 delayed: 66642 work_perf: 0 expires: 600 
elapsed: 6229 us
[  806.866893] dst_total: 155892 delayed: 66768 work_perf: 0 expires: 600 
elapsed: 6224 us
[  807.473041] dst_total: 156268 delayed: 66884 work_perf: 0 expires: 600 
elapsed: 6463 us
[  808.078979] dst_total: 156514 delayed: 67093 work_perf: 0 expires: 600 
elapsed: 6494 us
[  808.684670] dst_total: 156927 delayed: 67226 work_perf: 0 expires: 600 
elapsed: 6275 us
[  809.290646] dst_total: 157364 delayed: 67327 work_perf: 0 expires: 600 
elapsed: 6345 us
[  809.896516] dst_total: 157724 delayed: 67428 work_perf: 0 expires: 600 
elapsed: 6307 us
[  810.502756] dst_total: 157915 delayed: 67642 work_perf: 0 expires: 600 
elapsed: 6641 us
[  811.108374] dst_total: 158349 delayed: 67746 work_perf: 0 expires: 600 
elapsed: 6349 us
[  811.714508] dst_total: 158856 delayed: 67843 work_perf: 0 expires: 600 
elapsed: 6576 us
[  812.320241] dst_total: 159315 delayed: 67948 work_perf: 0 expires: 600 
elapsed: 6403 us
[  812.926305] dst_total: 159726 delayed: 68041 work_perf: 0 expires: 600 
elapsed: 6553 us
[  813.532064] dst_total: 159997 delayed: 68217 work_perf: 0 expires: 600 
elapsed: 6406 us
[  814.137984] dst_total: 160527 delayed: 68309 work_perf: 0 expires: 600 
elapsed: 6416 us
[  814.743949] dst_total: 160994 delayed: 68404 work_perf: 0 expires: 600 
elapsed: 6475 us
[  815.350120] dst_total: 161460 delayed: 68497 work_perf: 0 expires: 600 
elapsed: 6739 us
[  815.955683] dst_total: 161873 delayed: 68568 work_perf: 0 expires: 600 
elapsed: 6393 us
[  816.561587] dst_total: 162083 delayed: 68684 work_perf: 0 expires: 600 
elapsed: 6389 us
[  817.167555] dst_total: 162613 delayed: 68748 work_perf: 0 expires: 600 
elapsed: 6450 us
[  817.773653] dst_total: 163137 delayed: 68821 work_perf: 0 expires: 600 
elapsed: 6637 us
[  818.379400] dst_total: 163592 delayed: 68889 work_perf: 0 expires: 600 
elapsed: 6477 us
[  818.985324] dst_total: 164115 delayed: 68946 work_perf: 0 expires: 600 
elapsed: 6494 us
[  819.591212] dst_total: 164223 delayed: 69019 work_perf: 0 expires: 600 
elapsed: 6474 us
[  820.197032] dst_total: 164666 delayed: 69019 work_perf: 0 expires: 1600 
elapsed: 6387 us
[  821.802811] dst_total: 165685 delayed: 69019 work_perf: 0 expires: 3100 
elapsed: 6402 us
[  824.908547] dst_total: 167570 delayed: 69019 work_perf: 0 expires: 4967 
elapsed: 6588 us
[  829.881811] dst_total: 170472 delayed: 69019 work_perf: 0 expires: 7993 
elapsed: 6786 us
[  837.880254] dst_total: 175476 delayed: 69019 work_perf: 0 expires: 10993 
elapsed: 6455 us
[  848.878097] dst_total: 181394 delayed: 69019 work_perf: 0 expires: 13994 
elapsed: 6752 us
[  862.875836] dst_total: 190093 delayed: 69019 work_perf: 0 expires: 17994 
elapsed: 6633 us
[  880.873325] dst_total: 200983 delayed: 69019 work_perf: 0 expires: 22994 
elapsed: 6839 us
[  903.870309] dst_total: 207322 delayed: 69019 work_perf: 0 expires: 27993 
elapsed: 6522 us


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

