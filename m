From: Chuck Ebbert <cebbert@redhat.com>
Subject: Oops in 2.6.22.1: skb_copy_and_csum_datagram_iovec()
Date: Tue, 21 Aug 2007 16:04:11 -0400
Message-ID: <46CB453B.5040005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751560AbXHUUEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 16:04:12 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7LK4Cx9016311
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 16:04:12 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7LK4BNb026524
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 16:04:12 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id l7LK4Bd4014446
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 16:04:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=253290

18:57:54 osama kernel: BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
18:57:54 osama kernel:  printing eip:
18:57:54 osama kernel: c05c4026
18:57:54 osama kernel: *pde = 1d860067
18:57:54 osama kernel: *pte = 00000000
18:57:54 osama kernel: Oops: 0000 [#1]
18:57:54 osama kernel: SMP
18:57:54 osama kernel: last sysfs file: /power/state
18:57:54 osama kernel: Modules linked in: nfsd exportfs lockd nfs_acl autofs4 sunrpc dm_mirror dm_multipath dm_mod video sbs button dock battery ac ipv6 lp snd_via82xx snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_pcm snd_timer i2c_viapro snd_page_alloc i2c_core 8139cp snd_mpu401_uart floppy snd_rawmidi via_ircc snd_seq_device via_rhine 8139too irda snd mii crc_ccitt soundcore ns558 parport_pc gameport ide_cd rtc_cmos serio_raw parport cdrom ext2 mbcache ehci_hcd ohci_hcd uhci_hcd
18:57:54 osama kernel: CPU:    0
18:57:54 osama kernel: EIP:    0060:[<c05c4026>]    Not tainted VLI
18:57:54 osama kernel: EFLAGS: 00010246   (2.6.22.1-32.fc6 #1)
18:57:54 osama kernel: EIP is at skb_copy_and_csum_datagram_iovec+0x17/0xca
18:57:54 osama kernel: eax: d4341180   ebx: 00000000   ecx: 00000000   edx: 00000008
18:57:54 osama kernel: esi: d4341180   edi: 00000000   ebp: 00000008   esp: d488fd7c
18:57:54 osama kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
18:57:54 osama kernel: Process lockd (pid: 2567, ti=d488f000 task=d4876000 task.ti=d488f000)
18:57:54 osama kernel: Stack: 00000000 00000000 00000246 00000292 d4341180 d58bf660 d4879014 d488ff18
18:57:54 osama kernel:        c05ffaf7 d488fdb0 00000000 00000000 00000000 d4c30980 00000040 c07374c0
18:57:54 osama kernel:        d488ff18 d488ff18 c05be8a5 00000000 00000040 00000002 d488fdd8 00000010
18:57:54 osama kernel: Call Trace:
18:57:54 osama kernel:  [<c05ffaf7>] udp_recvmsg+0xdd/0x1cd
18:57:54 osama kernel:  [<c05be8a5>] sock_common_recvmsg+0x3e/0x54
18:57:54 osama kernel:  [<c05bd0fa>] sock_recvmsg+0xec/0x107
18:57:54 osama kernel:  [<c041d0c2>] update_curr+0x23b/0x25c
18:57:54 osama kernel:  [<c0433e31>] autoremove_wake_function+0x0/0x35
18:57:54 osama kernel:  [<c041ce20>] update_stats_wait_end+0x84/0xad
18:57:54 osama kernel:  [<c06278fe>] __reacquire_kernel_lock+0x2f/0x4b
18:57:54 osama kernel:  [<c041d87a>] enqueue_entity+0x276/0x294
18:57:54 osama kernel:  [<c05be67f>] kernel_recvmsg+0x31/0x40
18:57:54 osama kernel:  [<e0bc52d4>] svc_udp_recvfrom+0x114/0x368 [sunrpc]
18:57:54 osama kernel:  [<c0626888>] schedule_timeout+0x13/0x8f
18:57:54 osama kernel:  [<e0bc620e>] svc_recv+0x2e5/0x393 [sunrpc]
18:57:54 osama kernel:  [<c0430e7d>] create_workqueue_thread+0x38/0x49
18:57:54 osama kernel:  [<c041f109>] default_wake_function+0x0/0xc
18:57:54 osama kernel:  [<e0ac31fe>] lockd+0x108/0x222 [lockd]
18:57:54 osama kernel:  [<c0404e76>] ret_from_fork+0x6/0x20
18:57:54 osama kernel:  [<e0ac30f6>] lockd+0x0/0x222 [lockd]
18:57:54 osama kernel:  [<e0ac30f6>] lockd+0x0/0x222 [lockd]
18:57:54 osama kernel:  [<c0406177>] kernel_thread_helper+0x7/0x10
18:57:54 osama kernel:  =======================
18:57:54 osama kernel: Code: f6 75 04 31 c0 eb 05 b8 f2 ff ff ff 83 c4 30 5b 5e 5f 5d c3 55 89 d5 57 56 89 c6 53 89 cb 83 ec 10 8b 78 54 29 d7 eb 03 83 c3 08 <8b> 43 04 85 c0 74 f6 39 f8 73 26 89 f0 e8 fa fd ff ff 66 85 c0


Oops is here:

int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
                                     int hlen, struct iovec *iov)
{
        __wsum csum;
        int chunk = skb->len - hlen;

        /* Skip filled elements.
         * Pretty silly, look at memcpy_toiovec, though 8)
         */
====>   while (!iov->iov_len)
                iov++;


udp_recvmsg() passed a NULL iov to this function.

