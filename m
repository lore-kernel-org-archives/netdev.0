From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 12:34:02 +0200
Message-ID: <4A44A41A.6080608@gmail.com>
References: <4A439C6B.9090502@itcare.pl> <4A43E9F1.90209@cosmosbay.com> <4A43F1A2.3090108@itcare.pl> <4A440019.3020009@gmail.com> <4A449DAD.9030606@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45453 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbZFZKeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 06:34:11 -0400
In-Reply-To: <4A449DAD.9030606@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=B3 Staszewski a =E9crit :
> Eric Dumazet pisze:
>> Pawe=B3 Staszewski a =E9crit :
>> =20
>>> cat /proc/vmallocinfo
>>> 0xf7ffe000-0xf8000000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfe6a000 ioremap
>>> 0xf8000000-0xf8007000   28672 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfef5000 ioremap
>>> 0xf8008000-0xf800a000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfef2000 ioremap
>>> 0xf800c000-0xf800e000    8192
>>> acpi_ex_system_memory_space_handler+0xd6/0x208 phys=3Dfed1f000 iore=
map
>>> 0xf8010000-0xf8012000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfefb000 ioremap
>>> 0xf8014000-0xf8016000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfef4000 ioremap
>>> 0xf8018000-0xf801a000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfef3000 ioremap
>>> 0xf801c000-0xf801e000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfef1000 ioremap
>>> 0xf8020000-0xf8022000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfef0000 ioremap
>>> 0xf8024000-0xf8026000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfeef000 ioremap
>>> 0xf8028000-0xf802a000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfeee000 ioremap
>>> 0xf802c000-0xf802e000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfeed000 ioremap
>>> 0xf8030000-0xf8032000    8192 acpi_tb_verify_table+0x1d/0x46
>>> phys=3Ddfeec000 ioremap
>>> 0xf8038000-0xf803d000   20480 ich_force_enable_hpet+0x69/0x15a
>>> phys=3Dfed1c000 ioremap
>>> 0xf803e000-0xf8040000    8192 hpet_enable+0x2a/0x21b phys=3Dfed0000=
0
>>> ioremap
>>> 0xf8040000-0xf8046000   24576 alloc_iommu+0x18d/0x1d4 phys=3Dfeb000=
00
>>> ioremap
>>> 0xf8048000-0xf804a000    8192 pcim_iomap+0x2f/0x3a phys=3De1b21000 =
ioremap
>>> 0xf804c000-0xf804e000    8192 e1000_probe+0x229/0xa73 phys=3De1b200=
00
>>> ioremap
>>> 0xf804f000-0xf8051000    8192 reiserfs_init_bitmap_cache+0x32/0x65
>>> pages=3D1 vmalloc
>>> 0xf8052000-0xf8064000   73728 journal_init+0x30/0x82a pages=3D17 vm=
alloc
>>> 0xf8065000-0xf8067000    8192 reiserfs_allocate_list_bitmaps+0x27/0=
x7e
>>> pages=3D1 vmalloc
>>> 0xf8068000-0xf806a000    8192 reiserfs_allocate_list_bitmaps+0x27/0=
x7e
>>> pages=3D1 vmalloc
>>> 0xf806b000-0xf806d000    8192 reiserfs_allocate_list_bitmaps+0x27/0=
x7e
>>> pages=3D1 vmalloc
>>> 0xf806e000-0xf8070000    8192 reiserfs_allocate_list_bitmaps+0x27/0=
x7e
>>> pages=3D1 vmalloc
>>> 0xf8071000-0xf8073000    8192 reiserfs_allocate_list_bitmaps+0x27/0=
x7e
>>> pages=3D1 vmalloc
>>> 0xf8080000-0xf80a1000  135168 e1000_probe+0x1ca/0xa73 phys=3De1b000=
00
>>> ioremap
>>> 0xf80a2000-0xf80a6000   16384 e1000e_setup_rx_resources+0x20/0xf7
>>> pages=3D3 vmalloc
>>> 0xf80a7000-0xf80ab000   16384 e1000e_setup_tx_resources+0x17/0x96
>>> pages=3D3 vmalloc
>>> 0xf80ac000-0xf80b0000   16384 e1000e_setup_rx_resources+0x20/0xf7
>>> pages=3D3 vmalloc
>>> 0xf80b1000-0xf80b5000   16384 e1000e_setup_tx_resources+0x17/0x96
>>> pages=3D3 vmalloc
>>> 0xf80c0000-0xf80e1000  135168 e1000_probe+0x1ca/0xa73 phys=3De1a600=
00
>>> ioremap
>>> 0xf8100000-0xf8121000  135168 e1000_probe+0x1ca/0xa73 phys=3De1a200=
00
>>> ioremap
>>> 0xf8122000-0xf81b3000  593920 journal_init+0x65b/0x82a pages=3D144 =
vmalloc
>>> 0xf81b4000-0xf822f000  503808 sys_swapon+0x392/0x8f3 pages=3D122 vm=
alloc
>>> 0xf846a000-0xf856c000 1056768 tnode_new+0x35/0x65 pages=3D257 vmall=
oc
>>>    =20
>>
>> This is from a 32 bit kernel.
>>
>> This doesnt match your previous /proc/meminfo (from a 64bit kernel o=
n
>> a 12 GB machine)
>>
>> Of course, I would like /proc/vmallocinfo on your loaded router, not=
 from
>> a dev machine :)
>>
>>  =20
>=20
> Yes sorry for no info about it.
> I test the same kernel configurations on one 32bit machine and second=
 64bit
>=20
> here is meminfo from this 32bit machine working on kernel 2.6.30
> cat /proc/meminfo
> MemTotal:        3625444 kB
> MemFree:         3043648 kB
> Buffers:          133968 kB
> Cached:            36316 kB
> SwapCached:            0 kB
> Active:           256868 kB
> Inactive:          76252 kB
> Active(anon):     163064 kB
> Inactive(anon):        0 kB
> Active(file):      93804 kB
> Inactive(file):    76252 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:       2758160 kB
> HighFree:        2556136 kB
> LowTotal:         867284 kB
> LowFree:          487512 kB
> SwapTotal:        995896 kB
> SwapFree:         995896 kB
> Dirty:              3624 kB
> Writeback:             0 kB
> AnonPages:        162912 kB
> Mapped:             3612 kB
> Slab:             235888 kB
> SReclaimable:      46408 kB
> SUnreclaim:       189480 kB
> PageTables:          384 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     2808616 kB
> Committed_AS:     170648 kB
> VmallocTotal:     122880 kB
> VmallocUsed:        2876 kB
> VmallocChunk:     109824 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       4096 kB
> DirectMap4k:        8184 kB
> DirectMap4M:      901120 kB
> and vmallocinfo
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
> 0xf8bbc000-0xf8cbe000 1056768 tnode_new+0x35/0x65 pages=3D257 vmalloc
>=20
>=20
> And next  machine with kernel 2.6.29.3
> dmesg:
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> cat /proc/meminfo
> MemTotal:        2072652 kB
> MemFree:          496960 kB
> Buffers:          267620 kB
> Cached:           895212 kB
> SwapCached:            0 kB
> Active:           675744 kB
> Inactive:         703312 kB
> Active(anon):     215848 kB
> Inactive(anon):        0 kB
> Active(file):     459896 kB
> Inactive(file):   703312 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:       1186696 kB
> HighFree:         151156 kB
> LowTotal:         885956 kB
> LowFree:          345804 kB
> SwapTotal:       1975984 kB
> SwapFree:        1975984 kB
> Dirty:                20 kB
> Writeback:             0 kB
> AnonPages:        215724 kB
> Mapped:             6120 kB
> Slab:             186652 kB
> SReclaimable:     125832 kB
> SUnreclaim:        60820 kB
> PageTables:          416 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     3012308 kB
> Committed_AS:     223692 kB
> VmallocTotal:     122880 kB
> VmallocUsed:        3192 kB
> VmallocChunk:     108436 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       4096 kB
> DirectMap4k:        8184 kB
> DirectMap4M:      901120 kB
> cat /proc/vmallocinfo
> 0xf7ffe000-0xf8000000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3D7fee0000 ioremap
> 0xf8000000-0xf8005000   20480 acpi_tb_verify_table+0x1d/0x46
> phys=3D7fee3000 ioremap
> 0xf8006000-0xf8008000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3D7fee3000 ioremap
> 0xf800a000-0xf800c000    8192 acpi_tb_verify_table+0x1d/0x46
> phys=3D7fee6000 ioremap
> 0xf800d000-0xf800f000    8192 reiserfs_init_bitmap_cache+0x3b/0x80
> pages=3D1 vmalloc
> 0xf8010000-0xf8022000   73728 journal_init+0x30/0x8f0 pages=3D17 vmal=
loc
> 0xf8023000-0xf8025000    8192 reiserfs_allocate_list_bitmaps+0x2d/0x9=
0
> pages=3D1 vmalloc
> 0xf8026000-0xf8028000    8192 reiserfs_allocate_list_bitmaps+0x2d/0x9=
0
> pages=3D1 vmalloc
> 0xf8029000-0xf802b000    8192 reiserfs_allocate_list_bitmaps+0x2d/0x9=
0
> pages=3D1 vmalloc
> 0xf802c000-0xf802e000    8192 reiserfs_allocate_list_bitmaps+0x2d/0x9=
0
> pages=3D1 vmalloc
> 0xf802f000-0xf8031000    8192 reiserfs_allocate_list_bitmaps+0x2d/0x9=
0
> pages=3D1 vmalloc
> 0xf803e000-0xf8040000    8192 e1000_setup_all_tx_resources+0x57/0x660
> pages=3D1 vmalloc
> 0xf8040000-0xf8061000  135168 e1000_probe+0x207/0xeb0 phys=3Df5000000=
 ioremap
> 0xf8062000-0xf8064000    8192 e1000_setup_all_rx_resources+0x57/0x6d0
> pages=3D1 vmalloc
> 0xf8065000-0xf8067000    8192 e1000_setup_all_tx_resources+0x57/0x660
> pages=3D1 vmalloc
> 0xf8068000-0xf806a000    8192 e1000_setup_all_rx_resources+0x57/0x6d0
> pages=3D1 vmalloc
> 0xf806b000-0xf806d000    8192 e1000_setup_all_tx_resources+0x57/0x660
> pages=3D1 vmalloc
> 0xf806e000-0xf8070000    8192 e1000_setup_all_rx_resources+0x57/0x6d0
> pages=3D1 vmalloc
> 0xf8080000-0xf80a1000  135168 e1000_probe+0x207/0xeb0 phys=3Df1040000=
 ioremap
> 0xf80c0000-0xf80e1000  135168 e1000_probe+0x207/0xeb0 phys=3Df4000000=
 ioremap
> 0xf80e2000-0xf8173000  593920 journal_init+0x56e/0x8f0 pages=3D144 vm=
alloc
> 0xf8174000-0xf8267000  995328 sys_swapon+0x548/0xa30 pages=3D242 vmal=
loc
> 0xf8d17000-0xf8e19000 1056768 tnode_new+0x7f/0x90 pages=3D257 vmalloc
>=20
>=20
> because i have this info on 5 machines that working in ibgp mesh
> And only one 64bit dev machine that is one of failover member - but i
> kill this machine  after upgrade to kernel 2.6.31-rc1

Yes, I was a fool to ask you to try 2.6.31-rc1, sorry.

Even 2.6.30 is too young for a production machine.

2.6.29.5 contains the fixes, Pawel, did you tried this version ?
