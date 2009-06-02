From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 2 Jun 2009 11:12:45 +0100
Message-ID: <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	 <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
	 <20090521085116.GC2892@ami.dom.local>
	 <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
	 <20090523073201.GA2766@ami.dom.local>
	 <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
	 <20090528211258.GA3658@ami.dom.local>
	 <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com>
	 <20090530200756.GF3166@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:8150 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbZFBKMo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 06:12:44 -0400
Received: by an-out-0708.google.com with SMTP id d40so16742072and.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 03:12:46 -0700 (PDT)
In-Reply-To: <20090530200756.GF3166@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 9:07 PM, Jarek Poplawski wrote:
> Here is a tc patch, which should minimize these boundaries, so please=
,
> repeat this test with previous patches/conditions plus this one.
>
> Thanks,
> Jarek P.
> ---
>
> =A0tc/tc_core.c | =A0 10 +++++-----
> =A0tc/tc_core.h | =A0 =A04 ++--
> =A02 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/tc/tc_core.c b/tc/tc_core.c
> index 9a0ff39..6d74287 100644
> --- a/tc/tc_core.c
> +++ b/tc/tc_core.c
> @@ -27,18 +27,18 @@
> =A0static double tick_in_usec =3D 1;
> =A0static double clock_factor =3D 1;
>
> -int tc_core_time2big(unsigned time)
> +int tc_core_time2big(double time)
> =A0{
> - =A0 =A0 =A0 __u64 t =3D time;
> + =A0 =A0 =A0 __u64 t;
>
> - =A0 =A0 =A0 t *=3D tick_in_usec;
> + =A0 =A0 =A0 t =3D time * tick_in_usec + 0.5;
> =A0 =A0 =A0 =A0return (t >> 32) !=3D 0;
> =A0}
>
>
> -unsigned tc_core_time2tick(unsigned time)
> +unsigned tc_core_time2tick(double time)
> =A0{
> - =A0 =A0 =A0 return time*tick_in_usec;
> + =A0 =A0 =A0 return time * tick_in_usec + 0.5;
> =A0}
>
> =A0unsigned tc_core_tick2time(unsigned tick)
> diff --git a/tc/tc_core.h b/tc/tc_core.h
> index 5a693ba..0ac65aa 100644
> --- a/tc/tc_core.h
> +++ b/tc/tc_core.h
> @@ -13,8 +13,8 @@ enum link_layer {
> =A0};
>
>
> -int =A0tc_core_time2big(unsigned time);
> -unsigned tc_core_time2tick(unsigned time);
> +int =A0tc_core_time2big(double time);
> +unsigned tc_core_time2tick(double time);
> =A0unsigned tc_core_tick2time(unsigned tick);
> =A0unsigned tc_core_time2ktime(unsigned time);
> =A0unsigned tc_core_ktime2time(unsigned ktime);
>

I'm getting great values with this patch!

class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70970b/8 mpu 0b overhead 0b cburst
70970b/8 mpu 0b overhead 0b level 0
 Sent 14270693572 bytes 17928007 pkt (dropped 12579262, overlimits 0 re=
queues 0)
 rate 552755Kbit 86802pps backlog 0b 127p requeues 0
 lended: 17927880 borrowed: 0 giants: 0
 tokens: -16095 ctokens: -16095

(for packets of 800 bytes)
I'll get back to you with more values.

  Antonio Almeida
