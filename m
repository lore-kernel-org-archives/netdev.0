From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel memory
Date: Thu, 27 Jan 2011 14:54:42 +0800
Message-ID: <AANLkTinbg9Ox9QzW3JGHbWoctaQTY3oM2Lj=OSWyS1hK@mail.gmail.com>
References: <1296062517.2899.86.camel@edumazet-laptop> <1296063823.6115.37.camel@Joe-Laptop>
 <20110126.115530.226756606.davem@davemloft.net> <1296108251.2448.183.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, john.r.fastabend@intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49632 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab1A0GzL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 01:55:11 -0500
Received: by fxm20 with SMTP id 20so1806476fxm.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 22:55:10 -0800 (PST)
In-Reply-To: <1296108251.2448.183.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 2:04 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2011-01-26 at 11:55 -0800, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Wed, 26 Jan 2011 09:43:43 -0800
>> > On Wed, 2011-01-26 at 18:21 +0100, Eric Dumazet wrote:
>> >> mqprio_dump() should make sure all fields of struct tc_mqprio_qop=
t are
>> >> initialized.
>> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> >> CC: John Fastabend <john.r.fastabend@intel.com>
>> >> ---
>> >> =A0net/sched/sch_mqprio.c | =A0 =A02 +-
>> >> =A01 file changed, 1 insertion(+), 1 deletion(-)
>> >>
>> >> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
>> >> index fbc6f53..effd4ee 100644
>> >> --- a/net/sched/sch_mqprio.c
>> >> +++ b/net/sched/sch_mqprio.c
>> >> @@ -215,7 +215,7 @@ static int mqprio_dump(struct Qdisc *sch, str=
uct sk_buff *skb)
>> >> =A0 =A0struct net_device *dev =3D qdisc_dev(sch);
>> >> =A0 =A0struct mqprio_sched *priv =3D qdisc_priv(sch);
>> >> =A0 =A0unsigned char *b =3D skb_tail_pointer(skb);
>> >> - =A0struct tc_mqprio_qopt opt;
>> >> + =A0struct tc_mqprio_qopt opt =3D { 0 };
>> > I think the best style to use memset so that any
>> > possible struct padding is guaranteed to be zeroed.
>> Such padding does not exist, and we won't add such padding since thi=
s is
>> a user visible data structure and thus whose layout is cast in stone=
=2E
>
> /* MQPRIO */
> #define TC_QOPT_BITMASK 15
> #define TC_QOPT_MAX_QUEUE 16
>
> struct tc_mqprio_qopt {
> __u8 num_tc; // 1
> __u8 prio_tc_map[TC_QOPT_BITMASK + 1]; // 16
> __u8 hw; // 1
> __u16 count[TC_QOPT_MAX_QUEUE]; // 32
> __u16 offset[TC_QOPT_MAX_QUEUE]; //32
> };
>
> I believe this struct needs to be declared __packed.
>
> It could otherwise be 24 bytes not 22.
> Or if char array declarations have a different
> alignment requirement, could be any size.
>

The total size is 1 + 16 + 1 + 32 + 32 =3D 82.

How do you get 24 or 22?

> memset is better than {0}.
>


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
