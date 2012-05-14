From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v2] net: codel: fix build errors
Date: Tue, 15 May 2012 00:09:49 +0200
Message-ID: <CA+1xoqe6=nu0nvGVa_Hei+XVfRE0QaAtTa+n=ZQc22mj3Xm8Rg@mail.gmail.com>
References: <1337032626-7104-1-git-send-email-levinsasha928@gmail.com> <20120514150544.6b17d3c5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, dave.taht@bufferbloat.net,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120514150544.6b17d3c5@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2012 at 12:05 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 14 May 2012 23:57:06 +0200
> Sasha Levin <levinsasha928@gmail.com> wrote:
>
>> Fix the following build error:
>>
>> net/sched/sch_fq_codel.c: In function 'fq_codel_dump_stats':
>> net/sched/sch_fq_codel.c:464:3: error: unknown field 'qdisc_stats' s=
pecified in initializer
>> net/sched/sch_fq_codel.c:464:3: warning: missing braces around initi=
alizer
>> net/sched/sch_fq_codel.c:464:3: warning: (near initialization for 's=
t.<anonymous>')
>> net/sched/sch_fq_codel.c:465:3: error: unknown field 'qdisc_stats' s=
pecified in initializer
>> net/sched/sch_fq_codel.c:465:3: warning: excess elements in struct i=
nitializer
>> net/sched/sch_fq_codel.c:465:3: warning: (near initialization for 's=
t')
>> net/sched/sch_fq_codel.c:466:3: error: unknown field 'qdisc_stats' s=
pecified in initializer
>> net/sched/sch_fq_codel.c:466:3: warning: excess elements in struct i=
nitializer
>> net/sched/sch_fq_codel.c:466:3: warning: (near initialization for 's=
t')
>> net/sched/sch_fq_codel.c:467:3: error: unknown field 'qdisc_stats' s=
pecified in initializer
>> net/sched/sch_fq_codel.c:467:3: warning: excess elements in struct i=
nitializer
>> net/sched/sch_fq_codel.c:467:3: warning: (near initialization for 's=
t')
>> make[1]: *** [net/sched/sch_fq_codel.o] Error 1
>>
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>> ---
>> =A0net/sched/sch_fq_codel.c | =A0 =A09 +++++----
>> =A01 files changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
>> index a7b3754..337ff20 100644
>> --- a/net/sched/sch_fq_codel.c
>> +++ b/net/sched/sch_fq_codel.c
>> @@ -461,13 +461,14 @@ static int fq_codel_dump_stats(struct Qdisc *s=
ch, struct gnet_dump *d)
>> =A0 =A0 =A0 struct fq_codel_sched_data *q =3D qdisc_priv(sch);
>> =A0 =A0 =A0 struct tc_fq_codel_xstats st =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .type =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =3D TCA_FQ_CODEL_XSTATS_QDISC,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .qdisc_stats.maxpacket =A0 =A0 =A0 =A0 =A0=
=3D q->cstats.maxpacket,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .qdisc_stats.drop_overlimit =A0 =A0 =3D q-=
>drop_overlimit,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .qdisc_stats.ecn_mark =A0 =A0 =A0 =A0 =A0 =
=3D q->cstats.ecn_mark,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .qdisc_stats.new_flow_count =A0 =A0 =3D q-=
>new_flow_count,
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 struct list_head *pos;
>>
>> + =A0 =A0 st.qdisc_stats.maxpacket =3D q->cstats.maxpacket;
>> + =A0 =A0 st.qdisc_stats.drop_overlimit =3D q->drop_overlimit;
>> + =A0 =A0 st.qdisc_stats.ecn_mark =3D q->cstats.ecn_mark;
>> + =A0 =A0 st.qdisc_stats.new_flow_count =3D q->new_flow_count;
>> +
>> =A0 =A0 =A0 list_for_each(pos, &q->new_flows)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 st.qdisc_stats.new_flows_len++;
>>
>
> Cleaner and simpler to just use nested initialization.
> =A0 =A0 =A0 =A0struct tc_fq_codel_xstats st =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.type =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =3D TCA_FQ_CODEL_XSTATS_QDISC,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.qdisc_stats =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.maxpacket =A0 =A0 =A0=
=3D q->cstats.maxpacket,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.drop_overlimit =3D q-=
>drop_overlimit,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.ecn_mark =A0 =A0 =A0 =
=3D q->cstats.ecn_mark,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.new_flow_count =3D q-=
>new_flow_count,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0};

You'll get the same errors. You can't directly initialize members that
are in an anonymous union.
