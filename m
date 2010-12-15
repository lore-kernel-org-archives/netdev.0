From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 21:48:38 +0100
Message-ID: <1292446118.2603.11.camel@edumazet-laptop>
References: <cover.1292405004.git.fenghua.yu@intel.com>
	 <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Xinan Tang <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fenghua Yu <fenghua.yu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 12:02 -0800, Fenghua Yu a =C3=A9=
crit :
> From: Fenghua Yu <fenghua.yu@intel.com>
>=20
> Multiqueue and multicore provide packet parallel processing methodolo=
gy.
> Current kernel and network drivers place one queue on one core. But t=
he higher
> level socket doesn't know multiqueue. Current socket only can receive=
 or send
> packets through one network interfaces. In some cases e.g. multi bpf =
filter
> tcpdump and snort, a lot of contentions come from socket operations l=
ike ring
> buffer. Even if the application itself has been fully parallelized an=
d run on
> multi-core systems and NIC handlex tx/rx in multiqueue in parallel, n=
etwork layer
> and NIC device driver assemble packets to a single, serialized queue.=
 Thus the
> application cannot actually run in parallel in high speed.
>=20
> To break the serialized packets assembling bottleneck in kernel, one =
way is to
> allow socket to know multiqueue associated with a NIC interface. So e=
ach socket
> can handle tx/rx in one queue in parallel.
>=20
> Kernel provides several interfaces by which sockets can be bound to r=
x/tx queues.
> User applications can configure socket by providing several sockets t=
hat each
> bound to a single queue, applications can get data from kernel in par=
allel. After
> that, competitions mentioned above can be removed.
>=20
> With this patch, the user-space receiving speed on a Intel SR1690 ser=
ver with
> a single L5640 6-core processor and a single ixgbe-based NIC goes fro=
m 0.73Mpps
> to 4.20Mpps, nearly a linear speedup. A Intel SR1625 server two E5530=
 4-core
> processors and a single ixgbe-based NIC goes from 0.80Mpps to 4.6Mpps=
=2E We noticed
> the performance penalty comes from NUMA memory allocation.
>=20

??? please elaborate on these NUMA memory allocations. This should be O=
K
after commit 564824b0c52c34692d (net: allocate skbs on local node)

> This patch set provides kernel ioctl interfaces for user space. User =
space can
> either directly call the interfaces or libpcap interfaces can be furt=
her provided
> on the top of the kernel ioctl interfaces.

So, say we have 8 queues, you want libpcap opens 8 sockets, and bind
them to each queue. Add a bpf filter to each one of them. This seems no=
t
generic way, because it wont work for an UDP socket for example.
And you already can do this using SKF_AD_QUEUE (added in commit
d19742fb)

Also your AF_PACKET patch only address mmaped sockets.
