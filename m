From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 00:54:17 +0200
Message-ID: <4A440019.3020009@gmail.com>
References: <4A439C6B.9090502@itcare.pl> <4A43E9F1.90209@cosmosbay.com> <4A43F1A2.3090108@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47603 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287AbZFYWya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 18:54:30 -0400
In-Reply-To: <4A43F1A2.3090108@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=B3 Staszewski a =E9crit :
>=20
> cat /proc/vmallocinfo
> 0xf7ffe000-0xf8000000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfe6a000 ioremap
> 0xf8000000-0xf8007000   28672 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfef5000 ioremap
> 0xf8008000-0xf800a000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfef2000 ioremap
> 0xf800c000-0xf800e000    8192
> acpi_ex_system_memory_space_handler+0xd6/0x208 phys=3Dfed1f000 iorema=
p
> 0xf8010000-0xf8012000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfefb000 ioremap
> 0xf8014000-0xf8016000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfef4000 ioremap
> 0xf8018000-0xf801a000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfef3000 ioremap
> 0xf801c000-0xf801e000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfef1000 ioremap
> 0xf8020000-0xf8022000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfef0000 ioremap
> 0xf8024000-0xf8026000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfeef000 ioremap
> 0xf8028000-0xf802a000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfeee000 ioremap
> 0xf802c000-0xf802e000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfeed000 ioremap
> 0xf8030000-0xf8032000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3Ddfeec000 ioremap
> 0xf8038000-0xf803d000   20480 ich_force_enable_hpet+0x69/0x15a
> phys=3Dfed1c000 ioremap
> 0xf803e000-0xf8040000    8192 hpet_enable+0x2a/0x21b phys=3Dfed00000 =
ioremap
> 0xf8040000-0xf8046000   24576 alloc_iommu+0x18d/0x1d4 phys=3Dfeb00000=
 ioremap
> 0xf8048000-0xf804a000    8192 pcim_iomap+0x2f/0x3a phys=3De1b21000 io=
remap
> 0xf804c000-0xf804e000    8192 e1000_probe+0x229/0xa73 phys=3De1b20000=
 ioremap
> 0xf804f000-0xf8051000    8192 reiserfs_init_bitmap_cache+0x32/0x65
> pages=3D1 vmalloc
> 0xf8052000-0xf8064000   73728 journal_init+0x30/0x82a pages=3D17 vmal=
loc
> 0xf8065000-0xf8067000    8192 reiserfs_allocate_list_bitmaps+0x27/0x7=
e
> pages=3D1 vmalloc
> 0xf8068000-0xf806a000    8192 reiserfs_allocate_list_bitmaps+0x27/0x7=
e
> pages=3D1 vmalloc
> 0xf806b000-0xf806d000    8192 reiserfs_allocate_list_bitmaps+0x27/0x7=
e
> pages=3D1 vmalloc
> 0xf806e000-0xf8070000    8192 reiserfs_allocate_list_bitmaps+0x27/0x7=
e
> pages=3D1 vmalloc
> 0xf8071000-0xf8073000    8192 reiserfs_allocate_list_bitmaps+0x27/0x7=
e
> pages=3D1 vmalloc
> 0xf8080000-0xf80a1000  135168 e1000_probe+0x1ca/0xa73 phys=3De1b00000=
 ioremap
> 0xf80a2000-0xf80a6000   16384 e1000e_setup_rx_resources+0x20/0xf7
> pages=3D3 vmalloc
> 0xf80a7000-0xf80ab000   16384 e1000e_setup_tx_resources+0x17/0x96
> pages=3D3 vmalloc
> 0xf80ac000-0xf80b0000   16384 e1000e_setup_rx_resources+0x20/0xf7
> pages=3D3 vmalloc
> 0xf80b1000-0xf80b5000   16384 e1000e_setup_tx_resources+0x17/0x96
> pages=3D3 vmalloc
> 0xf80c0000-0xf80e1000  135168 e1000_probe+0x1ca/0xa73 phys=3De1a60000=
 ioremap
> 0xf8100000-0xf8121000  135168 e1000_probe+0x1ca/0xa73 phys=3De1a20000=
 ioremap
> 0xf8122000-0xf81b3000  593920 journal_init+0x65b/0x82a pages=3D144 vm=
alloc
> 0xf81b4000-0xf822f000  503808 sys_swapon+0x392/0x8f3 pages=3D122 vmal=
loc
> 0xf846a000-0xf856c000 1056768 tnode_new+0x35/0x65 pages=3D257 vmalloc

This is from a 32 bit kernel.

This doesnt match your previous /proc/meminfo (from a 64bit kernel on a=
 12 GB machine)

Of course, I would like /proc/vmallocinfo on your loaded router, not fr=
om
a dev machine :)

>=20
>=20
> Eric Dumazet pisze:
>> Pawe=B3 Staszewski a =E9crit :
>> =20
>>> Hello ALL
>>>
>>> Some time ago i report this:
>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
>>>
>>> and now with 2.6.29 / 2.6.29.1 / 2.6.29.3 and 2.6.30 it back
>>> dmesg output:
>>> oprofile: using NMI interrupt.
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>>>    =20
>>
>> Curious, you seem to hit an old alloc_pages limit()... (MAX_ORDER
>> allocation)
>>
>> Your root node has 2^18 =3D 262144 pointers of 8 bytes -> 2097152 by=
tes
>> (+ header -> 4194304 bytes)
>>
>> But since following commit, we should use vmalloc() so this
>> PAGE_SIZE<<10) limit
>> should not anymore be applied.
>>
>> Could you do a "cat /proc/vmallocinfo" just to check your big tnodes
>> are vmalloced() ?
>>
>>
>> commit 15be75cdb5db442d0e33d37b20832b88f3ccd383
>> Author: Stephen Hemminger <shemminger@vyatta.com>
>> Date:   Thu Apr 10 02:56:38 2008 -0700
>>
>>     IPV4: fib_trie use vmalloc for large tnodes
>>
>>     Use vmalloc rather than alloc_pages to avoid wasting memory.
>>     The problem is that tnode structure has a power of 2 sized array=
,
>>     plus a header. So the current code wastes almost half the memory
>>     allocated because it always needs the next bigger size to hold
>>     that small header.
>>
>>     This is similar to an earlier patch by Eric, but instead of a li=
st
>>     and lock, I used a workqueue to handle the fact that vfree can't
>>     be done in interrupt context.
>>
>>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>>
>> =20
>>> cat /proc/net/fib_triestat
>>> Basic info: size of leaf: 40 bytes, size of tnode: 56 bytes.
>>> Main:
>>>        Aver depth:     2.28
>>>        Max depth:      6
>>>        Leaves:         276539
>>>        Prefixes:       289922
>>>        Internal nodes: 66762
>>>          1: 35046  2: 13824  3: 9508  4: 4897  5: 2331  6: 1149  7:=
 5
>>> 9: 1  18: 1
>>>        Pointers: 691228
>>> Null ptrs: 347928
>>> Total size: 35709  kB
>>>
>>> Counters:
>>> ---------
>>> gets =3D 26276593
>>> backtracks =3D 547306
>>> semantic match passed =3D 26188746
>>> semantic match miss =3D 1117
>>> null node hit=3D 27285055
>>> skipped node resize =3D 0
>>>
>>> Local:
>>>        Aver depth:     3.33
>>>        Max depth:      4
>>>        Leaves:         9
>>>        Prefixes:       10
>>>        Internal nodes: 8
>>>          1: 8
>>>        Pointers: 16
>>> Null ptrs: 0
>>> Total size: 2  kB
>>>
>>> Counters:
>>> ---------
>>> gets =3D 26642350
>>> backtracks =3D 1282818
>>> semantic match passed =3D 18166
>>> semantic match miss =3D 0
>>> null node hit=3D 0
>>> skipped node resize =3D 0
>>>
>>>
>>>
>>> This machine is running bgpd with two bgp peers / full route table
>>>
>>> cat /proc/meminfo
>>> MemTotal:       12279032 kB
>>> MemFree:        11521920 kB
>>> Buffers:           80288 kB
>>> Cached:            34416 kB
>>> SwapCached:            0 kB
>>> Active:           286816 kB
>>> Inactive:          82024 kB
>>> Active(anon):     254296 kB
>>> Inactive(anon):        0 kB
>>> Active(file):      32520 kB
>>> Inactive(file):    82024 kB
>>> Unevictable:           0 kB
>>> Mlocked:               0 kB
>>> SwapTotal:        987988 kB
>>> SwapFree:         987988 kB
>>> Dirty:              1140 kB
>>> Writeback:             0 kB
>>> AnonPages:        254164 kB
>>> Mapped:             5440 kB
>>> Slab:             365084 kB
>>> SReclaimable:      28784 kB
>>> SUnreclaim:       336300 kB
>>> PageTables:         2104 kB
>>> NFS_Unstable:          0 kB
>>> Bounce:                0 kB
>>> WritebackTmp:          0 kB
>>> CommitLimit:     7127504 kB
>>> Committed_AS:     267704 kB
>>> VmallocTotal:   34359738367 kB
>>> VmallocUsed:       11824 kB
>>> VmallocChunk:   34359707815 kB
>>> HugePages_Total:       0
>>> HugePages_Free:        0
>>> HugePages_Rsvd:        0
>>> HugePages_Surp:        0
>>> Hugepagesize:       2048 kB
>>> DirectMap4k:        3392 kB
>>> DirectMap2M:    12578816 kB
>>>
>>>
>>> Interfaces mtu is1500
>>>    =20
>>
>>
>>
>>  =20
>=20
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

