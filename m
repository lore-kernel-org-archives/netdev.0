From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 13:35:52 -0600
Message-ID: <200501061335.55104.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501060926.54588.jeremy.guthrie@berbee.com> <16861.32852.11187.131058@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart11278716.QdpK7jeLio";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16861.32852.11187.131058@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart11278716.QdpK7jeLio
Content-Type: multipart/mixed;
  boundary="Boundary-01=_YMZ3BgNw2vwGpSi"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_YMZ3BgNw2vwGpSi
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 06 January 2005 12:15 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > I still don't see the rt_cache_stat file even under 2.4.28 stock.  See
>  > below.
>  >
>  > ls -la /proc/net/stat/
>  > total 0
>  > -r--r--r--  1 root root 0 Jan  6 09:22 rt_cache
>
>  rtstat is replaced by lnstat which is in iproute2 package:
>  http://developer.osdl.org/dev/iproute2/download/
>
>  (Old version=20
> ftp://robur.slu.se/pub/Linux/net-development/rt_cache_stat/rtstat.c)
Please see the attachment.

>  > cat /proc/net/softnet_stat
>  > 96deb140 0032844e 00012bbb 00000fd8 00000000 00000000 00000000 00000000
>  > 00000dd4
>  > 00013dda 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>  > 0000041f
>
>  You only use CPU0 for packet processing. Also it seems you use  the
> non-NAPI version of e1000.
The E1000 driver is the stock driver in 2.4.28.

>
>  > cat /proc/interrupts
>  >            CPU0       CPU1
>  >   0:     821852    5664906    IO-APIC-edge  timer
>  >   1:        484       1247    IO-APIC-edge  keyboard
>  >   8:          0          2    IO-APIC-edge  rtc
>  >  14:          5         16    IO-APIC-edge  ide0
>  >  18: 1928608529       1374   IO-APIC-level  eth3
>  >  20:          1  226113098   IO-APIC-level  eth2
>  >  27:       7950      34312   IO-APIC-level  eth0
>
>  Traffic is flowing from eth3->eth2 Why all the interrupts on eth2/CPU1?
>  Is traffic most unidirectional?
eth2 is TX only.  We don't receive anything on it.  This system should only=
=20
ever RX on eth3 and TX on eth2 as part of its function.  Eth0 is the=20
management interface on the host.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--Boundary-01=_YMZ3BgNw2vwGpSi
Content-Type: text/plain;
  charset="iso-8859-1";
  name="results-2.4.28.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="results-2.4.28.txt"

arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|
 entries|  allocs|destroys|hash_gro| lookups|    hits|res_fail|rcv_prob|rcv_prob|periodic|forced_g|forced_g| entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis| entries|  allocs|destroys|hash_gro| lookups|    hits|res_fail|rcv_prob|rcv_prob|periodic|forced_g|forced_g|
        |        |        |      ws|        |        |      ed|es_mcast|es_ucast|_gc_runs|  c_runs|c_goal_m|        |        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|        |        |        |      ws|        |        |      ed|es_mcast|es_ucast|_gc_runs|  c_runs|c_goal_m|
        |        |        |        |        |        |        |        |        |        |        |     iss|        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |     iss|
      22|       9|     425|       1|   17202|   14599|       0|       0|       0|   75743|       0|       0|   61129|    6329|   20428|       0|       0|    1539|       0|       0|       8|      28|       0|    1677|    1675|       0|       0|  143038|     145|       0|       0|       0|       0|       0|       0|       0|       0|       0|    4649|       0|       0|
      22|       0|       0|       0|       1|       1|       0|       0|       0|       2|       0|       0|   62833|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      10|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       1|       1|       0|       0|       0|       1|       0|       0|   64306|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   65602|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   59707|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   60684|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   62249|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   62249|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   65000|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   58800|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   58800|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   62135|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   63677|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   63677|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   59013|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   59013|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|   62462|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|   62462|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       1|       0|       0|       0|       0|       4|       0|       0|   65225|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       1|       0|       0|       0|       0|       4|       0|       0|   65225|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|
 entries|  allocs|destroys|hash_gro| lookups|    hits|res_fail|rcv_prob|rcv_prob|periodic|forced_g|forced_g| entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis| entries|  allocs|destroys|hash_gro| lookups|    hits|res_fail|rcv_prob|rcv_prob|periodic|forced_g|forced_g|
        |        |        |      ws|        |        |      ed|es_mcast|es_ucast|_gc_runs|  c_runs|c_goal_m|        |        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|        |        |        |      ws|        |        |      ed|es_mcast|es_ucast|_gc_runs|  c_runs|c_goal_m|
        |        |        |        |        |        |        |        |        |        |        |     iss|        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |     iss|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|   60904|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|   60904|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   63890|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   63890|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|   59738|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|   59738|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   63346|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      13|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   63346|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      13|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       0|       0|       0|       0|       4|       0|       0|   58798|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      13|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       0|       0|       0|       0|       4|       0|       0|   58798|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      13|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   62518|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      13|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   62518|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      13|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       2|       2|       0|       0|       0|       3|       0|       0|   65364|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      12|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       2|       2|       0|       0|       0|       3|       0|       0|   65364|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      12|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       2|       2|       0|       0|       0|       4|       0|       0|   61111|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      11|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       2|       2|       0|       0|       0|       4|       0|       0|   61111|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      11|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   63152|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       6|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   63152|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       6|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   58223|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       4|       0|       0|   58223|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|arp_cach|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|clip_arp|
 entries|  allocs|destroys|hash_gro| lookups|    hits|res_fail|rcv_prob|rcv_prob|periodic|forced_g|forced_g| entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis| entries|  allocs|destroys|hash_gro| lookups|    hits|res_fail|rcv_prob|rcv_prob|periodic|forced_g|forced_g|
        |        |        |      ws|        |        |      ed|es_mcast|es_ucast|_gc_runs|  c_runs|c_goal_m|        |        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|        |        |        |      ws|        |        |      ed|es_mcast|es_ucast|_gc_runs|  c_runs|c_goal_m|
        |        |        |        |        |        |        |        |        |        |        |     iss|        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |        |     iss|
      24|       0|       0|       0|       2|       2|       0|       0|       0|       4|       0|       0|   62044|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      15|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       2|       2|       0|       0|       0|       4|       0|       0|   62044|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      15|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   64932|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|   64932|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      25|       0|       0|       0|       2|       2|       0|       0|       0|       4|       0|       0|   60712|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      14|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       1|       0|       1|       1|       0|       0|       0|       2|       0|       0|   62304|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      10|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   63758|       1|       1|       0|       0|       1|       0|       0|       0|       0|       0|       1|       1|       0|       0|       8|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       1|       0|       0|   64967|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       2|       0|       0|   58931|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   60836|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       6|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       2|       0|       0|   62574|       1|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      11|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   64121|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       1|       0|       0|   65615|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      10|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       2|       0|       0|   60057|       1|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      11|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      23|       0|       0|       0|       1|       1|       0|       0|       0|       1|       0|       0|   62008|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       1|       1|       0|       0|       0|       1|       0|       0|   63651|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       1|       1|       0|       0|       0|       1|       0|       0|   63651|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      22|       0|       0|       0|       1|       1|       0|       0|       0|       1|       0|       0|   63651|       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      25|       0|       0|       0|       2|       2|       0|       0|       0|       6|       0|       0|   61300|       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      12|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
      24|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|       0|   63087|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|

--Boundary-01=_YMZ3BgNw2vwGpSi--

--nextPart11278716.QdpK7jeLio
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3ZMbqtjaBHGZBeURAn36AJ0ZgrFrRrZ0ltYkf+9wcVopJboaBQCZAamg
RbifMHm5Th0HwiWo6rysTbk=
=TL7p
-----END PGP SIGNATURE-----

--nextPart11278716.QdpK7jeLio--
