From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Mon, 12 Aug 2013 13:40:07 +0800
Message-ID: <52087537.6060200@windriver.com>
References: <1375772225-19265-1-git-send-email-fan.du@windriver.com> <20130806092220.GH25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43543 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab3HLFhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 01:37:24 -0400
In-Reply-To: <20130806092220.GH25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8806=E6=97=A5 17:22, Steffen Klassert wrote:
> On Tue, Aug 06, 2013 at 02:57:05PM +0800, Fan Du wrote:
>> xfrm_state timer should be independent of system clock change,
>> so switch to monotonic clock base.
>>
>
> I think a monotonic timer will reintroduce a bug on suspend/resume
> that was fixed by commit 9e0d57fd6
> (xfrm: SAD entries do not expire correctly after suspend-resume)
>
> Please make sure that this does not happen.

What about using CLOCK_BOOTTIME? it's monotonic, but includes suspend t=
ime as well.


 From 1dae5a22c203224ee46e2a2f95b569a04b74117b Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Mon, 12 Aug 2013 13:33:45 +0800
Subject: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic

xfrm_state timer should be independent of system clock change,
so switch to CLOCK_BOOTTIME base which is not only monotonic but
also counting suspend time.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
  net/xfrm/xfrm_state.c |    2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..1df4436 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -499,7 +499,7 @@ struct xfrm_state *xfrm_state_alloc(struct net *net=
)
  		INIT_HLIST_NODE(&x->bydst);
  		INIT_HLIST_NODE(&x->bysrc);
  		INIT_HLIST_NODE(&x->byspi);
-		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_REALTIME,=
 HRTIMER_MODE_ABS);
+		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_BOOTTIME,=
 HRTIMER_MODE_ABS);
  		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
  				(unsigned long)x);
  		x->curlft.add_time =3D get_seconds();
--=20
1.7.9.5




> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
