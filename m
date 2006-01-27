From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 11:52:27 -0800
Message-ID: <20060127195227.GA3565@localhost.localdomain>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932499AbWA0Tw1@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43D9DFA1.9070802@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2006 at 09:53:53AM +0100, Eric Dumazet wrote:
> Ravikiran G Thirumalai a =E9crit :
> >Change the atomic_t sockets_allocated member of struct proto to a=20
> >per-cpu counter.
> >
> >Signed-off-by: Pravin B. Shelar <pravins@calsoftinc.com>
> >Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> >Signed-off-by: Shai Fultheim <shai@scalex86.org>
> >
> Hi Ravikiran
>=20
> If I correctly read this patch, I think there is a scalability proble=
m.
>=20
> On a big SMP machine, read_sockets_allocated() is going to be a real =
killer.
>=20
> Say we have 128 Opterons CPUS in a box.

read_sockets_allocated is being invoked when when /proc/net/protocols i=
s read,
which can be assumed as not frequent. =20
At sk_stream_mem_schedule(), read_sockets_allocated() is invoked only=20
certain conditions, under memory pressure -- on a large CPU count machi=
ne,=20
you'd have large memory, and I don't think read_sockets_allocated would=
 get=20
called often.  It did not atleast on our 8cpu/16G box.  So this should =
be OK=20
I think.

There're no 128 CPU Opteron boxes yet afaik ;).

Thanks,
Kiran
