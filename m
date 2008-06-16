From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:29:01 +0200
Message-ID: <4856DB1D.80503@cosmosbay.com>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com> <20080616211213.M76390@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:49451 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470AbYFPV3J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:29:09 -0400
In-Reply-To: <20080616211213.M76390@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a =C3=A9crit :
>> Are you sure nf_conntrack or ip route cache is not killing you ?
>>
>> Filling 512 or 1024 RX ring on Gigabit link can be very fast, especi=
ally=20
>> if ip route cache is full.
>>
>> rtstat -c10 -i1
>=20
> conntrack disabled, it is just enabled for second on load and then un=
loaded.

ok :)

>=20
> MegaRouter-KARAM ~ # rtstat -c10 -i1
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_ca=
che|rt_cache|
>  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_mar=
ti|
> out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlis=
t|out_hlis|
>         |        |     tot|      mc|     ute|        |  an_dst|  an_s=
rc|    =20
>   |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_s=
earch|
>    63448|229209146|22225578|   13754|      12|    2822|       0|     =
104| =20
> 54647|   27606|     570|21782075|21776859|      74|       0|215222374=
|   61294|
>    66085|  141462|    5268|       8|       0|       4|       0|      =
 0|    =20
>  4|       2|       0|    5274|    5274|       0|       0|  254424|   =
   10|
>    59947|  132660|   20570|       4|       0|       4|       0|      =
 0|    =20
>  8|      14|       0|   20584|   20584|       0|       0|  185738|   =
   24|
>    56995|  132416|   16918|      12|       0|       2|       0|      =
 0|    =20
>  6|       4|       0|   16932|   16932|       0|       0|   68378|   =
    8|
>    56422|  137058|   12336|       8|       0|       0|       0|      =
 0|    =20
>  8|       2|       0|   12344|   12344|       0|       0|   84022|   =
    4|
>    56819|  140526|    9896|      10|       0|       0|       0|      =
 0|    =20
>  6|       0|       0|    9898|    9896|       0|       0|   99138|   =
    4|
>    57580|  136936|    8370|      10|       0|       2|       0|      =
 0|    =20
>  8|       6|       2|    8378|    8378|       0|       0|  110834|   =
   22|
>    51583|  120138|   26828|      20|       0|       0|       0|      =
 0|    =20
>  4|       8|       0|   26848|   26848|       0|       0|   99292|   =
   24|
>    49354|  128076|   21606|      14|       0|       2|       0|      =
 0|    =20
>  0|      10|       0|   21626|   21626|       0|       0|   60546|   =
   12|
>=20
>=20
>=20

Hum... typical IP route cache congestion ?

echo 1 >/proc/sys/net/ipv4/route/gc_interval
echo 2 >/proc/sys/net/ipv4/route/gc_elasticity

You might want to boot with rhash_entries=3D131071 to play with IP rout=
e cache size, but I am not sure your workload can fit.




