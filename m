From: Jonathan Thibault <jonathan@navigue.com>
Subject: Re: large divisor for flow classifier
Date: Fri, 15 Oct 2010 19:52:41 -0400
Message-ID: <4CB8E949.60902@navigue.com>
References: <4CB899F7.0@navigue.com> <1287172905.2799.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:40892 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab0JOXxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 19:53:06 -0400
In-Reply-To: <1287172905.2799.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merci beaucoup :),

It at least shows I wasn't just confused about the way it works.  In it=
s planned final form, the rate will be set around 175Mbit.  I don't nee=
d perfect distribution so things should be fine as long as hosts cannot=
 easily cheat their way into having more bandwidth merely by creating m=
ore flows.

Jonathan

On 15/10/10 04:01 PM, Eric Dumazet wrote:
> Le vendredi 15 octobre 2010 =C3=A0 14:14 -0400, Jonathan Thibault a =C3=
=A9crit :
>=20
> SFQ is limited to a 1024 divisor
>=20
> You might try following patch :
>=20
> (8192 is the smallest power of two greater than 6144)
>=20
> sizeof(struct sfq_sched_data) becomes 0x2ccc instead of 0x10cc
>=20
> keep in mind hash distribution is not perfect.
>=20
> What would be the real rate ?
>=20
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..c4a53d6 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -77,7 +77,7 @@
>  	It is easy to increase these values, but not in flight.  */
> =20
>  #define SFQ_DEPTH		128
> -#define SFQ_HASH_DIVISOR	1024
> +#define SFQ_HASH_DIVISOR	8192
> =20
>  /* This type should contain at least SFQ_DEPTH*2 values */
>  typedef unsigned char sfq_index;
>=20
>=20
