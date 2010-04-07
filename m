From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Wed, 07 Apr 2010 17:07:47 +0800
Message-ID: <1270631267.2078.380.camel@ymzhang.sh.intel.com>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>
	 <alpine.DEB.2.00.1003250942080.2670@router.home>
	 <1269570902.9614.92.camel@alexs-hp.sh.intel.com>
	 <1270114166.2078.107.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004011050340.16531@router.home>
	 <1270195589.2078.116.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004050853300.23149@router.home>
	 <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>
	 <4BBA8DF9.8010409@kernel.org>
	 <1270542497.2078.123.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004061033330.18750@router.home>
	 <alpine.DEB.2.00.1004061552500.19151@router.home>
	 <1270591841.2091.170.camel@edumazet-laptop>
	 <1270607668.2078.259.camel@ymzhang.sh.intel.com>
	 <1270622352.2091.702.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>, alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31312 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab0DGJFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 05:05:49 -0400
In-Reply-To: <1270622352.2091.702.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-07 at 08:39 +0200, Eric Dumazet wrote:
> Le mercredi 07 avril 2010 =E0 10:34 +0800, Zhang, Yanmin a =E9crit :
>=20
> > I collected retired instruction, dtlb miss and LLC miss.
> > Below is data of LLC miss.
> >=20
> > Kernel 2.6.33:
> > # Samples: 11639436896 LLC-load-misses
> > #
> > # Overhead          Command                                        =
   Shared Object  Symbol
> > # ........  ...............  ......................................=
=2E...............  ......
> > #
> >     20.94%        hackbench  [kernel.kallsyms]                     =
                  [k] copy_user_generic_string
> >     14.56%        hackbench  [kernel.kallsyms]                     =
                  [k] unix_stream_recvmsg
> >     12.88%        hackbench  [kernel.kallsyms]                     =
                  [k] kfree
> >      7.37%        hackbench  [kernel.kallsyms]                     =
                  [k] kmem_cache_free
> >      7.18%        hackbench  [kernel.kallsyms]                     =
                  [k] kmem_cache_alloc_node
> >      6.78%        hackbench  [kernel.kallsyms]                     =
                  [k] kfree_skb
> >      6.27%        hackbench  [kernel.kallsyms]                     =
                  [k] __kmalloc_node_track_caller
> >      2.73%        hackbench  [kernel.kallsyms]                     =
                  [k] __slab_free
> >      2.21%        hackbench  [kernel.kallsyms]                     =
                  [k] get_partial_node
> >      2.01%        hackbench  [kernel.kallsyms]                     =
                  [k] _raw_spin_lock
> >      1.59%        hackbench  [kernel.kallsyms]                     =
                  [k] schedule
> >      1.27%        hackbench  hackbench                             =
                  [.] receiver
> >      0.99%        hackbench  libpthread-2.9.so                     =
                  [.] __read
> >      0.87%        hackbench  [kernel.kallsyms]                     =
                  [k] unix_stream_sendmsg
> >=20
> >=20
> >=20
> >=20
> > Kernel 2.6.34-rc3:
> > # Samples: 13079611308 LLC-load-misses
> > #
> > # Overhead          Command                                        =
                 Shared Object  Symbol
> > # ........  ...............  ......................................=
=2E.............................  ......
> > #
> >     18.55%        hackbench  [kernel.kallsyms]                     =
                                [k] copy_user_generic_str
> > ing
> >     13.19%        hackbench  [kernel.kallsyms]                     =
                                [k] unix_stream_recvmsg
> >     11.62%        hackbench  [kernel.kallsyms]                     =
                                [k] kfree
> >      8.54%        hackbench  [kernel.kallsyms]                     =
                                [k] kmem_cache_free
> >      7.88%        hackbench  [kernel.kallsyms]                     =
                                [k] __kmalloc_node_track_
> > caller
> >      6.54%        hackbench  [kernel.kallsyms]                     =
                                [k] kmem_cache_alloc_node
> >      5.94%        hackbench  [kernel.kallsyms]                     =
                                [k] kfree_skb
> >      3.48%        hackbench  [kernel.kallsyms]                     =
                                [k] __slab_free
> >      2.15%        hackbench  [kernel.kallsyms]                     =
                                [k] _raw_spin_lock
> >      1.83%        hackbench  [kernel.kallsyms]                     =
                                [k] schedule
> >      1.82%        hackbench  [kernel.kallsyms]                     =
                                [k] get_partial_node
> >      1.59%        hackbench  hackbench                             =
                                [.] receiver
> >      1.37%        hackbench  libpthread-2.9.so                     =
                                [.] __read
> >=20
> >=20
>=20
> Please check values of /proc/sys/net/core/rmem_default
> and /proc/sys/net/core/wmem_default on your machines.
>=20
> Their values can also change hackbench results, because increasing
> wmem_default allows af_unix senders to consume much more skbs and str=
ess
> slab allocators (__slab_free), way beyond slub_min_order can tune the=
m.
>=20
> When 2000 senders are running (and 2000 receivers), we might consume
> something like 2000 * 100.000 bytes of kernel memory for skbs. TLB
> trashing is expected, because all these skbs can span many 2MB pages.
> Maybe some node imbalance happens too.
It's a good pointer. rmem_default and wmem_default are about 116k on my=
 machine.
I changed them to 52K and it seems there is no improvement.

>=20
>=20
>=20
> You could try to boot your machine with less ram per node and check :
>=20
> # cat /proc/buddyinfo=20
> Node 0, zone      DMA      2      1      2      2      1      1      =
1      0      1      1      3=20
> Node 0, zone    DMA32    219    298    143    584    145     57     4=
4     41     31     26    517=20
> Node 1, zone    DMA32      4      1     17      1      0      3      =
2      2      2      2    123=20
> Node 1, zone   Normal    126    169     83      8      7      5     5=
9     59     49     28    459=20
>=20
>=20
> One experiment on your Nehalem machine would be to change hackbench s=
o
> that each group (20 senders/ 20 receivers) run on a particular NUMA
> node.
I expect process scheduler to work well in scheduling different groups
to different nodes.

I suspected dynamic percpu data didn't take care of NUMA, but kernel du=
mp shows
it does take care of NUMA.

>=20
> x86info -c ->
>=20
> CPU #1
> EFamily: 0 EModel: 1 Family: 6 Model: 26 Stepping: 5
> CPU Model: Core i7 (Nehalem)
> Processor name string: Intel(R) Xeon(R) CPU           X5570  @ 2.93GH=
z
> Type: 0 (Original OEM)	Brand: 0 (Unsupported)
> Number of cores per physical package=3D8
> Number of logical processors per socket=3D16
> Number of logical processors per core=3D2
> APIC ID: 0x10	Package: 0  Core: 1   SMT ID 0
> Cache info
>  L1 Instruction cache: 32KB, 4-way associative. 64 byte line size.
>  L1 Data cache: 32KB, 8-way associative. 64 byte line size.
>  L2 (MLC): 256KB, 8-way associative. 64 byte line size.
> TLB info
>  Data TLB: 4KB pages, 4-way associative, 64 entries
>  64 byte prefetching.
> Found unknown cache descriptors: 55 5a b2 ca e4=20
>=20
>=20


