From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 02 Apr 2005 16:10:10 +0200
Message-ID: <424EA7C2.6060308@cosmosbay.com>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>	<424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16974.41648.568927.54429@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson a =E9crit :
> Eric Dumazet writes:

>  Yes thats a pretty much load. Very short flows some reason?

Well... yes. This is a real server, not a DOS simulation.
1 million TCP flows, and about 3 million peers using UDP frames.

>  What's your ip_rt_gc_min_interval? GC should be allowed to=20
>  run frequent to smoothen out the GC load. Also good idea=20
>  to decrease gc_thresh and you hash is really huge.

No. As soon as I lower gc_thresh (and let gc running), the machine starts=
 to drop connections and crash some seconds later.
I found I had to make the hash table very large (but lowering elasticity,=
 ie chain length) .
It needs lot of ram, but at least CPU usage of net/ipv4/route.c is close =
to 0.

# grep . /proc/sys/net/ipv4/route/*
/proc/sys/net/ipv4/route/error_burst:5000
/proc/sys/net/ipv4/route/error_cost:1000
/proc/sys/net/ipv4/route/gc_elasticity:2
/proc/sys/net/ipv4/route/gc_interval:1
/proc/sys/net/ipv4/route/gc_min_interval:0
/proc/sys/net/ipv4/route/gc_min_interval_ms:500
/proc/sys/net/ipv4/route/gc_thresh:2900000
/proc/sys/net/ipv4/route/gc_timeout:155
/proc/sys/net/ipv4/route/max_delay:10
/proc/sys/net/ipv4/route/max_size:16777216
/proc/sys/net/ipv4/route/min_adv_mss:256
/proc/sys/net/ipv4/route/min_delay:2
/proc/sys/net/ipv4/route/min_pmtu:552
/proc/sys/net/ipv4/route/mtu_expires:600
/proc/sys/net/ipv4/route/redirect_load:20
/proc/sys/net/ipv4/route/redirect_number:9
/proc/sys/net/ipv4/route/redirect_silence:20480
/proc/sys/net/ipv4/route/secret_interval:36000
