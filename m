From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 22:05:56 +0300
Message-ID: <1206644756.2109.34.camel@iris.sw.ru>
References: <20080327062502.M51594@visp.net.lb>
	 <20080326.234049.256533912.davem@davemloft.net>
	 <47EB46BD.2080001@cosmosbay.com> <20080327144102.M65267@visp.net.lb>
	 <47EBB4A3.4090102@cosmosbay.com> <20080327151520.M89250@visp.net.lb>
	 <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb>
	 <47EBEDC9.6080100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47EBEDC9.6080100@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-03-27 at 19:56 +0100, Eric Dumazet wrote:
> Denys Fedoryshchenko a =E9crit :
> > Here is output from dmesg with patch you supplied.
> >
> > Kup /config # rtstat -i60 -c60
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_c=
ache|
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_c=
ache|
> > rt_cache|
> >  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_m=
arti|=20
> > out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hl=
ist|
> > out_hlis|
> >         |        |     tot|      mc|     ute|        |  an_dst| =20
> > an_src|        |    _tot|     _mc|        |      ed|    miss| verfl=
ow|=20
> > _search|t_search|
> >   103266|   69986|   11574|       0|      54|       0|       0|    =
   0|   =20
> > 1982|     634|       0|   10984|   10980|       0|       0|  191808=
|    5254|
> >   124787|   45125|    6019|       0|      28|       0|       0|    =
   0|    =20
> > 807|     230|       0|    6277|    6274|       0|       0|  128922|=
    2518|
> >   120270|   45588|    6288|       0|      30|       0|       0|    =
   0|    =20
> > 883|     214|       0|    6532|    6529|       0|       0|  125651|=
    2743|
> >   122253|   46522|    6582|       0|      27|       0|       0|    =
   0|    =20
> > 897|     213|       0|    6822|    6819|       0|       0|  124927|=
    2761|
> >
> > [  102.534363] dst_total: 120397 delayed: 12 work_perf: 0 expires: =
27999=20
> > elapsed: 1 us
> > [  130.530240] dst_total: 124277 delayed: 12 work_perf: 0 expires: =
32998=20
> > elapsed: 2 us
> > [  163.523240] dst_total: 110006 delayed: 12 work_perf: 0 expires: =
39000=20
> > elapsed: 1 us
> > [  202.519402] dst_total: 130453 delayed: 12 work_perf: 0 expires: =
45998=20
> > elapsed: 1 us
> > [  248.511220] dst_total: 110637 delayed: 12 work_perf: 0 expires: =
52600=20
> > elapsed: 2 us
> > [  301.102445] dst_total: 129366 delayed: 12 work_perf: 0 expires: =
60696=20
> > elapsed: 6 us
> >
> > After while
> >
> > Kup /config # rtstat -i300 -c60
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_c=
ache|
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_c=
ache|
> > rt_cache|
> >  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_m=
arti|=20
> > out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hl=
ist|
> > out_hlis|
> >         |        |     tot|      mc|     ute|        |  an_dst| =20
> > an_src|        |    _tot|     _mc|        |      ed|    miss| verfl=
ow|=20
> > _search|t_search|
> >   129138|   64166|    9864|       0|      46|       0|       0|    =
   0|   =20
> > 1334|     358|       0|   10012|   10008|       0|       0|  173006=
|    3985|
> >   130125|   43971|   10829|       0|      70|       0|       0|    =
   0|    =20
> > 907|     195|       0|   11093|   11090|       0|       0|  100601|=
    2848|
> >   144857|   32041|   22233|       0|     234|       0|       0|    =
   0|    =20
> > 738|     261|       0|   22727|   22724|       2|       0|   42769|=
     811|
> >
> > [  687.740779] dst_total: 129365 delayed: 12 work_perf: 0 expires: =
104999=20
> > elapsed: 1 us
> > [  792.736043] dst_total: 127247 delayed: 101589 work_perf: 0 expir=
es: 600=20
> > elapsed: 11274 us
> > [  793.347127] dst_total: 122440 delayed: 101589 work_perf: 0 expir=
es: 1600=20
> > elapsed: 11150 us
> > [  794.957419] dst_total: 123780 delayed: 101589 work_perf: 0 expir=
es: 3100=20
> > elapsed: 10896 us
> > [  798.068614] dst_total: 121992 delayed: 101589 work_perf: 0 expir=
es: 5655=20
> > elapsed: 11561 us
> > [  803.734450] dst_total: 120552 delayed: 101589 work_perf: 0 expir=
es: 7988=20
> > elapsed: 12254 us
> > [  811.733227] dst_total: 121105 delayed: 101589 work_perf: 0 expir=
es: 10988=20
> > elapsed: 12209 us
> > [  822.733196] dst_total: 120142 delayed: 101589 work_perf: 0 expir=
es: 13987=20
> > elapsed: 12039 us
> > [  836.730637] dst_total: 120823 delayed: 101589 work_perf: 0 expir=
es: 17987=20
> > elapsed: 12448 us
> > [  854.726913] dst_total: 127478 delayed: 101589 work_perf: 0 expir=
es: 22988=20
> > elapsed: 11435 us
> > [  877.724827] dst_total: 127497 delayed: 101589 work_perf: 0 expir=
es: 27987=20
> > elapsed: 12833 us
> > [  905.719818] dst_total: 126693 delayed: 101589 work_perf: 0 expir=
es: 32987=20
> > elapsed: 12068 us
> > [  938.714595] dst_total: 130740 delayed: 101589 work_perf: 0 expir=
es: 38988=20
> > elapsed: 11970 us
> > [  977.707568] dst_total: 135449 delayed: 101589 work_perf: 0 expir=
es: 45989=20
> > elapsed: 11747 us
> > [ 1023.701554] dst_total: 141181 delayed: 101589 work_perf: 0 expir=
es: 52988=20
> > elapsed: 12653 us
> > [ 1076.694012] dst_total: 147895 delayed: 101588 work_perf: 1 expir=
es: 59987=20
> > elapsed: 12217 us
> > [ 1136.684805] dst_total: 154798 delayed: 101588 work_perf: 0 expir=
es: 67987=20
> > elapsed: 12026 us
> > [ 1204.673424] dst_total: 163376 delayed: 101588 work_perf: 0 expir=
es: 76988=20
> > elapsed: 11151 us
> >
> > and after 30 minutes more
> >
> > Kup /config # rtstat -i300 -c60
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_c=
ache|
> > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_c=
ache|
> > rt_cache|
> >  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_m=
arti|=20
> > out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hl=
ist|
> > out_hlis|
> >         |        |     tot|      mc|     ute|        |  an_dst| =20
> > an_src|        |    _tot|     _mc|        |      ed|    miss| verfl=
ow|=20
> > _search|t_search|
> >   194841|  176962|   77964|       0|     684|       1|       0|    =
   0|   =20
> > 3939|    1143|       0|   79531|   79516|       7|       0|  401258=
|    9455|
> >   223224|   28262|   26499|       0|     236|       0|       0|    =
   0|    =20
> > 661|     216|       0|   26951|   26947|       3|       0|   93059|=
    1946|
> >   248425|   28257|   26784|       0|     226|       0|       0|    =
   0|    =20
> > 678|     202|       0|   27211|   27208|       3|       0|  115593|=
    2412|
> >   272823|   28943|   26728|       0|     246|       0|       0|    =
   0|    =20
> > 695|     200|       0|   27174|   27171|       3|       0|  135256|=
    2942|
> >   295087|   28835|   26701|       0|     252|       0|       0|    =
   0|    =20
> > 687|     194|       0|   27146|   27143|       3|       0|  154269|=
    3312|
> >
> >
> > [ 2043.547879] dst_total: 242922 delayed: 101588 work_perf: 0 expir=
es: 119987=20
> > elapsed: 12519 us
> > [ 2163.529997] dst_total: 252951 delayed: 101588 work_perf: 0 expir=
es: 119987=20
> > elapsed: 13930 us
> > [ 2283.512215] dst_total: 262678 delayed: 101588 work_perf: 0 expir=
es: 119986=20
> > elapsed: 14330 us
> > [ 2403.508447] dst_total: 271930 delayed: 101588 work_perf: 0 expir=
es: 119972=20
> > elapsed: 15230 us
> > [ 2523.476844] dst_total: 288046 delayed: 101588 work_perf: 0 expir=
es: 119985=20
> > elapsed: 15018 us
> > [ 2643.456996] dst_total: 296475 delayed: 101588 work_perf: 0 expir=
es: 119987=20
> > elapsed: 13654 us
> > [ 2763.438267] dst_total: 305033 delayed: 101588 work_perf: 0 expir=
es: 119987=20
> > elapsed: 13137 us
> >
> >  =20
>=20
> Very interesting... you can see 101588 dst are *delayed* in dst_garba=
ge,=20
> but apparently never freed.
>=20
> Something is wrong, but the count seems stable. Must be some kind of=20
> event, admin driven or something...
> might be the "ip route flush cache" that is schedlued around 600 seco=
nds=20
> of machine alive, then secret_interval seconds later...
>=20
> Typically, when a "ip route flush cache" is done (manually or trigger=
ed=20
> by secret_interval timer), refcounted>0 entries are put into dst_garb=
age.
>=20
> Then when some trafic occurs on the flows involved, IP stack should=20
> decrement refcount so that next dst_garbage round can free the delete=
d=20
> entries. Normal TCP connections are doing this correctly. On your=20
> machine, nothing.
>=20
> Possibly idle tcp sessions ?
>=20
> Maybe some netfilter problem ?
>=20
> Please tell us more about your machine ;)

could you check the patch sent yesterday by Pavel under the name
[PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code (v2).

It can fit the case, massive DST leakage is possible here.

Regards,
	Den

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
