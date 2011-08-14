From: Kevin Winchester <kjwinchester@gmail.com>
Subject: =?windows-1252?Q?sch=5Fgeneric=3A_warning=3A_the_comparison_will_always_eva?=
	=?windows-1252?Q?luate_as_=91true=92_for_the_address_of_=91noop=5Fqdisc=92_will?=
	=?windows-1252?Q?_never_be_NULL?=
Date: Sun, 14 Aug 2011 10:44:26 -0300
Message-ID: <CAELBVzA-ArFvp9MRp5ZvgsEpi4ikt9Nq=zHsNSLAOiD=TqZC=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: hadi@cyberus.ca, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With:

gcc (GCC) 4.6.1

I noticed the following warning appearing in my build:

net/sched/sch_generic.c: In function =91dev_graft_qdisc=92:
net/sched/sch_generic.c:678:2: warning: the comparison will always
evaluate as =91true=92 for the address of =91noop_qdisc=92 will never b=
e NULL
[-Waddress]

The code in question runs:


        /* ... and graft new one */
        if (qdisc =3D=3D NULL)
                qdisc =3D &noop_qdisc;
        dev_queue->qdisc_sleeping =3D qdisc;
        rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);

where rcu_assign_pointer has a null check that does not apply to
noop_qdisc, which will never be null.

My question is, should that really be assigning &noop_qdisc in there?
It seems odd to assign &noop_qdisc to qdisc only if qdisc is null, and
then unconditionally assign &noop_qdisc into dev_queue->qdisc.

Should the line be:

        rcu_assign_pointer(dev_queue->qdisc, qdisc);

instead?

Just curious,

--=20
Kevin Winchester
