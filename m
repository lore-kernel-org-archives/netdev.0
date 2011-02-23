From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: long word align struct qdisc_skb_cb data
Date: Wed, 23 Feb 2011 18:05:07 +0100
Message-ID: <1298480707.3301.386.camel@edumazet-laptop>
References: <20110221160306.GA9650@tuxdriver.com>
	 <1298308283.2849.5.camel@edumazet-laptop>
	 <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>  <4D6534C3.1080305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:34042 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab1BWRFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 12:05:16 -0500
Received: by bwz10 with SMTP id 10so333090bwz.10
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 09:05:15 -0800 (PST)
In-Reply-To: <4D6534C3.1080305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 17:24 +0100, Patrick McHardy a =
=C3=A9crit :
> Am 23.02.2011 16:14, schrieb Eric Dumazet:
> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> > index 16626a0..f40d32e 100644
> > --- a/include/net/sch_generic.h
> > +++ b/include/net/sch_generic.h
> > @@ -218,6 +218,7 @@ struct tcf_proto {
> > =20
> >  struct qdisc_skb_cb {
> >  	unsigned int		pkt_len;
> > +	unsigned int		sfb_classid;
> >  	char			data[];
> >  };
>=20
> This could be moved into a SFB specific cb, similar to what netem
> does.

Hmm... well... I want to be sure no other sch will destroy my values.

netem seems buggy then.

Probably following patch is needed ?

Thanks

[PATCH] net_sched: long word align struct qdisc_skb_cb data

netem_skb_cb() does :

return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;

Unfortunatly struct qdisc_skb_cb data is not long word aligned, so
access to psched_time_t time_to_send uses a non aligned access.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sch_generic.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 16626a0..dbdf2b5 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -218,7 +218,7 @@ struct tcf_proto {
=20
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
-	char			data[];
+	long			data[];
 };
=20
 static inline int qdisc_qlen(struct Qdisc *q)


