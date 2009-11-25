From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Wed, 25 Nov 2009 12:35:03 +0100
Message-ID: <4B0D1667.8050506@gmail.com>
References: <20091124.093956.247147202.davem@davemloft.net> <1259085412.2631.48.camel@ppwaskie-mobl2> <4B0C2547.8030408@gmail.com> <20091124.105442.06273019.davem@davemloft.net> <4B0C2CCA.6030006@gmail.com> <87iqczwtia.fsf@basil.nowhere.org> <4B0C4624.9080607@gmail.com> <4B0D0742.2050301@gmail.com> <20091125103713.GF29096@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54050 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758725AbZKYLfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 06:35:19 -0500
In-Reply-To: <20091125103713.GF29096@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Works here
>> dmesg | grep -i node
>> [    0.000000] SRAT: PXM 0 -> APIC 0 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 1 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 2 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 3 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 4 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 5 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 6 -> Node 0
>> [    0.000000] SRAT: PXM 0 -> APIC 7 -> Node 0
>=20
> You seem to only have 8 CPUs (one socket) Normally a dual socket neha=
lem
> should have 16 with HyperThreading enabled.
>=20
> For some reason the BIOS is not reporting the other CPU.
>=20
> You could double check with acpidmp / iasl -d if that's
> what the BIOS really reports, but normally it should work.
>=20

Good Lord, I had a CONFIG_NR_CPUS=3D16 in my .config.

Changing to to 32 or 64 seems better :)

# dmesg | grep -i node
[    0.000000] SRAT: PXM 0 -> APIC 0 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 1 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 2 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 3 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 4 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 5 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 6 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 7 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 16 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 17 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 18 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 19 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 20 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 21 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 22 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 23 -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 0-e0000000
[    0.000000] SRAT: Node 0 PXM 0 100000000-220000000
[    0.000000] SRAT: Node 1 PXM 1 220000000-420000000
[    0.000000] Bootmem setup node 0 0000000000000000-0000000220000000
[    0.000000]   NODE_DATA [0000000000001000 - 0000000000005fff]
[    0.000000] Bootmem setup node 1 0000000220000000-000000041ffff000
[    0.000000]   NODE_DATA [0000000220000000 - 0000000220004fff]
[    0.000000]  [ffffea0000000000-ffffea00087fffff] PMD -> [ffff8800286=
00000-ffff8800305fffff] on node 0
[    0.000000]  [ffffea0008800000-ffffea00107fffff] PMD -> [ffff8802202=
00000-ffff8802281fffff] on node 1
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[5] active PFN ranges
[    0.000000] On node 0 totalpages: 2094543
[    0.000000] On node 1 totalpages: 2097151
[    0.000000] NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:32 nr_node_ids:=
2
[    0.000000] SLUB: Genslabs=3D14, HWalign=3D64, Order=3D0-3, MinObjec=
ts=3D0, CPUs=3D32, Nodes=3D2
[    0.004830] Inode-cache hash table entries: 1048576 (order: 11, 8388=
608 bytes)
[    0.007291] CPU 0/0x0 -> Node 0
[    0.398106] CPU 1/0x10 -> Node 1
[    0.557857] CPU 2/0x4 -> Node 0
[    0.717609] CPU 3/0x14 -> Node 1
[    0.877359] CPU 4/0x2 -> Node 0
[    1.037112] CPU 5/0x12 -> Node 1
[    1.196862] CPU 6/0x6 -> Node 0
[    1.356614] CPU 7/0x16 -> Node 1
[    1.516368] CPU 8/0x1 -> Node 0
[    1.676117] CPU 9/0x11 -> Node 1
[    1.835867] CPU 10/0x5 -> Node 0
[    1.995619] CPU 11/0x15 -> Node 1
[    2.155370] CPU 12/0x3 -> Node 0
[    2.315122] CPU 13/0x13 -> Node 1
[    2.474873] CPU 14/0x7 -> Node 0
[    2.634624] CPU 15/0x17 -> Node 1


Thanks Andi
