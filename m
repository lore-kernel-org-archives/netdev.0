From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables --
 proto.sockets_allocated
Date: Fri, 27 Jan 2006 12:16:02 -0800
Message-ID: <20060127121602.18bc3f25.akpm@osdl.org>
References: <20060126185649.GB3651@localhost.localdomain>
	<20060126190357.GE3651@localhost.localdomain>
	<43D9DFA1.9070802@cosmosbay.com>
	<20060127195227.GA3565@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161003AbWA0UQo@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060127195227.GA3565@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
> On Fri, Jan 27, 2006 at 09:53:53AM +0100, Eric Dumazet wrote:
> > Ravikiran G Thirumalai a =E9crit :
> > >Change the atomic_t sockets_allocated member of struct proto to a=20
> > >per-cpu counter.
> > >
> > >Signed-off-by: Pravin B. Shelar <pravins@calsoftinc.com>
> > >Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> > >Signed-off-by: Shai Fultheim <shai@scalex86.org>
> > >
> > Hi Ravikiran
> >=20
> > If I correctly read this patch, I think there is a scalability prob=
lem.
> >=20
> > On a big SMP machine, read_sockets_allocated() is going to be a rea=
l killer.
> >=20
> > Say we have 128 Opterons CPUS in a box.
>=20
> read_sockets_allocated is being invoked when when /proc/net/protocols=
 is read,
> which can be assumed as not frequent. =20
> At sk_stream_mem_schedule(), read_sockets_allocated() is invoked only=
=20
> certain conditions, under memory pressure -- on a large CPU count mac=
hine,=20
> you'd have large memory, and I don't think read_sockets_allocated wou=
ld get=20
> called often.  It did not atleast on our 8cpu/16G box.  So this shoul=
d be OK=20
> I think.

That being said, the percpu_counters aren't a terribly successful conce=
pt
and probably do need a revisit due to the high inaccuracy at high CPU
counts.  It might be better to do some generic version of vm_acct_memor=
y()
instead.

If the benchmarks say that we need to.  If we cannot observe any proble=
ms
in testing of existing code and if we can't demonstrate any benefit fro=
m
the patched code then one option is to go off and do something else ;)
