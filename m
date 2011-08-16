From: Bernd Schubert <bernd.schubert-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Subject: Re: [Bug 41212] New: [regression] [3.1-git] ipoib causes kernel panic
 (NULL pointer dereference)
Date: Tue, 16 Aug 2011 12:34:38 +0200
Message-ID: <4E4A47BE.9090903@fastmail.fm>
References: <bug-41212-11804@https.bugzilla.kernel.org/> <CAAk-MO8EToGY4OhmX1xPN01iAXR9WSsJXWxHG9EVyrSGYP3h5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAAk-MO8EToGY4OhmX1xPN01iAXR9WSsJXWxHG9EVyrSGYP3h5w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Erez,

are you sure? Commit 69cce1d1404968f78b177a0314f5822d5afdbbfb is not in 
3.0 yet and I also don't see how 3.0 should fail there, as it tests 
immediately for "if (likely(skb_dst(skb)"


Thanks,
Bernd

On 08/16/2011 10:06 AM, Erez Shitrit wrote:
> Hi,
> it happened in 3.0 also, if you take the git tag v3.0-rc7 and below it
> will work.
>
> Thanks, Erez
>
> On Mon, Aug 15, 2011 at 6:40 PM, <bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
> <mailto:bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>> wrote:
>
>     https://bugzilla.kernel.org/show_bug.cgi?id=41212
>
>                Summary: [regression] [3.1-git] ipoib causes kernel panic
>     (NULL
>                         pointer dereference)
>                Product: Networking
>                Version: 2.5
>         Kernel Version: 3.1-git
>               Platform: All
>             OS/Version: Linux
>                   Tree: Mainline
>                 Status: NEW
>               Severity: normal
>               Priority: P1
>              Component: Other
>             AssignedTo: acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org
>     <mailto:acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
>             ReportedBy: bernd.schubert-97jfqw80gc6171pxa8y+qA@public.gmane.org
>     <mailto:bernd.schubert-97jfqw80gc6171pxa8y+qA@public.gmane.org>
>                     CC: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>     <mailto:linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>             Regression: Yes
>
>
>     Each time when I start IPoIB with any 3.1-rcX git version I tested
>     so far I get
>     a kernel panic. This didn't happen in 3.0 yet.
>
>
>     fslab2 login: [  114.392408] EXT4-fs (sdc): barriers disabled
>     [  114.449737] EXT4-fs (sdc): mounted filesystem with writeback data
>     mode.
>     Opts: journal_async_commit,barrier=0,data=writeback
>     [  240.944030] BUG: unable to handle kernel NULL pointer dereference at
>     0000000000000040
>     [  240.948007] IP: [<ffffffffa0366ce9>] ipoib_start_xmit+0x39/0x280
>     [ib_ipoib]
>     [  240.948007] PGD 1f964f067 PUD 1f9bf2067 PMD 0
>     [  240.948007] Oops: 0000 [#1] SMP
>     [  240.948007] CPU 1
>     [  240.948007] Modules linked in: ext4 mbcache jbd2 crc16 nfsd
>     ib_umad rdma_ucm
>     rdma_cm iw_cm ib_addr ib_uverbs ib_ipoib sg ib_cm ib_sa ipv6 sd_mod
>     crc_t10dif
>     loop arcmsr md_mod pcspkr ib_mthca ib_mad ib_core 8250_pnp fuse
>     af_packet nfs
>     lockd fscache auth_rpcgss nfs_acl sunrpc btrfs lzo_decompress
>     lzo_compress
>     zlib_deflate crc32c libcrc32c crypto_hash crypto_algapi ata_generic
>     pata_acpi
>     e1000 pata_amd sata_nv libata scsi_mod unix [last unloaded:
>     scsi_wait_scan]
>     [  240.948007]
>     [  240.948007] Pid: 0, comm: kworker/0:0 Not tainted 3.1.0-rc2+ #29
>     Supermicro
>     H8DCE/H8DCE
>     [  240.948007] RIP: 0010:[<ffffffffa0366ce9>]  [<ffffffffa0366ce9>]
>     ipoib_start_xmit+0x39/0x280 [ib_ipoib]
>     [  240.948007] RSP: 0018:ffff8801ffc03c10  EFLAGS: 00010246
>     [  240.948007] RAX: 0000000000000000 RBX: ffff8801f99ea000 RCX:
>     0000000000004420
>     [  240.948007] RDX: 0000000000000000 RSI: ffff8801f99ea000 RDI:
>     ffff8801f9afd500
>     [  240.948007] RBP: ffff8801ffc03c40 R08: ffff8801f940d49c R09:
>     ffff8801f9852240
>     [  240.948007] R10: 0000000000000000 R11: 0000000000000020 R12:
>     ffff8801f9afd500
>     [  240.948007] R13: 0000000000000050 R14: ffff8801f99ea600 R15:
>     ffff8801f9852280
>     [  240.948007] FS:  00007f0b66016700(0000) GS:ffff8801ffc00000(0000)
>     knlGS:0000000000000000
>     [  240.948007] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>     [  240.948007] CR2: 0000000000000040 CR3: 00000001f9a65000 CR4:
>     00000000000006e0
>     [  240.948007] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>     0000000000000000
>     [  240.948007] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>     0000000000000400
>     [  240.948007] Process kworker/0:0 (pid: 0, threadinfo
>     ffff8800bfe82000, task
>     ffff8800bfe6f1a0)
>     [  240.948007] Stack:
>     [  240.948007]  0000000000000010 ffff8801f9afd500 0000000000004420
>     0000000000000050
>     [  240.948007]  ffff8801f99ea000 ffff8801f9852280 ffff8801ffc03ca0
>     ffffffff812cd5e0
>     [  240.948007]  0000000000000001 ffffffffa03721a0 ffffffff8131f680
>     ffff8801fa110540
>     [  240.948007] Call Trace:
>     [  240.948007] <IRQ>
>     [  240.948007]  [<ffffffff812cd5e0>] dev_hard_start_xmit+0x2a0/0x590
>     [  240.948007]  [<ffffffff8131f680>] ? arp_create+0x70/0x200
>     [  240.948007]  [<ffffffff812e8e1f>] sch_direct_xmit+0xef/0x1c0
>     [  240.948007]  [<ffffffff812cd9f9>] dev_queue_xmit+0x129/0x3b0
>     [  240.948007]  [<ffffffff8131f853>] arp_send+0x43/0x50
>     [  240.948007]  [<ffffffff8131f96b>] arp_solicit+0x10b/0x240
>
>     --
>     Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
>     ------- You are receiving this mail because: -------
>     You are on the CC list for the bug.
>     --
>     To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>     the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>     <mailto:majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>     More majordomo info at http://vger.kernel.org/majordomo-info.html
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
