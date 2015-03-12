From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] fib_trie: Only display main table in /proc/net/route
Date: Thu, 12 Mar 2015 12:56:05 -0700
Message-ID: <5501EF55.6010703@gmail.com>
References: <20150311233536.1696.1657.stgit@ahduyck-vm-fedora20> <1426187629.11398.172.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:40047 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbbCLT4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 15:56:07 -0400
Received: by pdbfp1 with SMTP id fp1so22625014pdb.7
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 12:56:07 -0700 (PDT)
In-Reply-To: <1426187629.11398.172.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2015 12:13 PM, Eric Dumazet wrote:
> Alex,
>
> I caught this message with latest net-next
>
> [   31.449563] WARNING: CPU: 2 PID: 10307 at net/ipv4/fib_trie.c:1124 fib_table_insert+0x467/0x4d0()
> [   31.449564] Modules linked in: w1_therm wire cdc_acm ehci_pci ehci_hcd i2c_dev i2c_i801 i2c_core msr cpuid ib_uverbs mlx4_ib ib_sa ib_mad ib_core ib_addr ip6table_mangle ip6_tables ipv6 xt_multiport iptable_mangle
> [   31.449576] CPU: 2 PID: 10307 Comm: route Not tainted 4.0.0-smp-DEV #1321
> [   31.449578]  ffffffff8197e8b3 ffff883ff235fa78 ffffffff8160c40f 00000000000000d5
> [   31.449579]  0000000000000000 ffff883ff235fab8 ffffffff810a35d7 0000000000000000
> [   31.449581]  0000000000000000 000000007f000000 ffff883ff235fb90 0000000000000008
> [   31.449582] Call Trace:
> [   31.449587]  [<ffffffff8160c40f>] dump_stack+0x45/0x57
> [   31.449591]  [<ffffffff810a35d7>] warn_slowpath_common+0x97/0xe0
> [   31.449592]  [<ffffffff810a363a>] warn_slowpath_null+0x1a/0x20
> [   31.449594]  [<ffffffff815e5fc7>] fib_table_insert+0x467/0x4d0
> [   31.449597]  [<ffffffff815e10de>] ip_rt_ioctl+0x30e/0x460
> [   31.449599]  [<ffffffff811e0000>] ? do_readv_writev+0x70/0x2e0
> [   31.449601]  [<ffffffff815d9485>] inet_ioctl+0x65/0x90
> [   31.449604]  [<ffffffff81541e90>] sock_do_ioctl+0x30/0x70
> [   31.449606]  [<ffffffff81541fef>] routing_ioctl+0x11f/0x220
> [   31.449608]  [<ffffffff81546c68>] ? sk_prot_alloc+0x48/0x1a0
> [   31.449610]  [<ffffffff811e0000>] ? do_readv_writev+0x70/0x2e0
> [   31.449611]  [<ffffffff81542a52>] compat_sock_ioctl+0x702/0x930
> [   31.449613]  [<ffffffff81542d11>] ? sock_alloc_file+0x91/0x120
> [   31.449616]  [<ffffffff811fc7bb>] ? __fd_install+0x2b/0x60
> [   31.449617]  [<ffffffff811fc815>] ? fd_install+0x25/0x30
> [   31.449619]  [<ffffffff81542deb>] ? sock_map_fd+0x4b/0x70
> [   31.449621]  [<ffffffff81230233>] compat_SyS_ioctl+0xf3/0x1220
> [   31.449624]  [<ffffffff8157f27e>] ? compat_SyS_socketcall+0x9e/0x4a0
> [   31.449626]  [<ffffffff81095dec>] ? do_page_fault+0xc/0x10
> [   31.449629]  [<ffffffff81614c93>] sysenter_dispatch+0x7/0x1a
> [   31.449630] ---[ end trace 0f37afa3e6f481a5 ]---

The WARN_ON that is being triggered here is indicating that you have a
route that had identical prefix length, tos, and priority but belonged
to the other half of the merged table.

It should probably just be dropped though as I don't know if it is
really necessary.  I assume I could probably go though and just verify
the ordering for insertion so that we have local and then main in such a
case.

- Alex
