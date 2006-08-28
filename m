From: cagri coltekin <cagri@ripe.net>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Mon, 28 Aug 2006 02:49:07 +0200
Message-ID: <20060828004906.GC20092@ripe.net>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:28548 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S1751278AbWH1AtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2006 20:49:09 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 10:16:56AM +1000, Herbert Xu wrote:
> cagri coltekin <cagri@ripe.net> wrote:
> > 
> > Aug 25 04:03:35 ns kernel: ------------[ cut here ]------------
> > Aug 25 04:03:35 ns kernel: kernel BUG at net/ipv6/ip6_output.c:718!
> > Aug 25 04:03:35 ns kernel: invalid operand: 0000 [#1]
> > Aug 25 04:03:35 ns kernel: SMP 
> > Aug 25 04:03:35 ns kernel: Modules linked in: uhci_hcd ehci_hcd ohci_hcd aic7xxx ide_cd
> > Aug 25 04:03:35 ns kernel: CPU:    3
> > Aug 25 04:03:35 ns kernel: EIP:    0060:[svc_create_socket+189/416]    Not tainted VLI
> > Aug 25 04:03:35 ns kernel: EFLAGS: 00010282   (2.6.12.6-ncc-server) 
> 
> This is an ancient kernel.  Please really try 2.6.17 instead of just
> talking about it (the line number confirms that it is 2.6.12).

Ooops, sorry for the confusion. It happens with 2.6.17 too (see
below), cut&paste from wrong log. The rest of the data provided
in the previous message is actually fresh.

Aug 26 07:09:36 ns kernel: [17180077.732000] ------------[ cut here ]------------
Aug 26 07:09:36 ns kernel: [17180077.792000] kernel BUG at net/ipv6/ip6_output.c:693!
Aug 26 07:09:36 ns kernel: [17180077.856000] invalid opcode: 0000 [#1]
Aug 26 07:09:36 ns kernel: [17180077.900000] SMP 
Aug 26 07:09:36 ns kernel: [17180077.928000] Modules linked in: ide_cd cdrom
Aug 26 07:09:36 ns kernel: [17180077.980000] CPU:    2
Aug 26 07:09:36 ns kernel: [17180077.980000] EIP:    0060:[ip6_fragment+619/1981]    Not tainted VLI
Aug 26 07:09:36 ns kernel: [17180077.980000] EFLAGS: 00010282   (2.6.17.11-ns-debug #6) 
Aug 26 07:09:36 ns kernel: [17180078.148000] EIP is at ip6_fragment+0x26b/0x7bd
Aug 26 07:09:36 ns kernel: [17180078.204000] eax: fffffff2   ebx: fffffdd8   ecx: 000005b8   edx: f5ecc600
Aug 26 07:09:36 ns kernel: [17180078.288000] esi: f5ecc7f8   edi: f5e7bff0   ebp: c2ff6780   esp: f71f5bb8
Aug 26 07:09:36 ns kernel: [17180078.376000] ds: 007b   es: 007b   ss: 0068
Aug 26 07:09:36 ns kernel: [17180078.428000] Process named (pid: 1811, threadinfo=f71f4000 task=f7470a10)
Aug 26 07:09:36 ns kernel: [17180078.508000] Stack: f7208880 000007e0 f5e7bff8 fffffdd8 f71f4000 f71f5bdc 5d000000 00000000 
Aug 26 07:09:36 ns kernel: [17180078.612000]        000007e0 0e030000 ffffffee 000007e0 fffffddc f5e7bff0 f7fd7880 f5ecc048 
Aug 26 07:09:36 ns kernel: [17180078.720000]        f7208880 f7fd7880 f5ecc040 f774c080 c02adcc6 f7208880 c02adac2 c02afcc6 
Aug 26 07:09:36 ns kernel: [17180078.824000] Call Trace:
Aug 26 07:09:36 ns kernel: [17180078.860000]  <c02adcc6> ip6_output+0x3c/0x4c  <c02adac2> ip6_output2+0x0/0x1c8
Aug 26 07:09:36 ns kernel: [17180078.948000]  <c02afcc6> ip6_push_pending_frames+0x250/0x390  <c02c09ea> udp_v6_push_pending_frames+0x13d/0x1a4
Aug 26 07:09:36 ns kernel: [17180079.072000]  <c02c0fdb> udpv6_sendmsg+0x58a/0x953  <c0291d36> udp_recvmsg+0x56/0x24c
Aug 26 07:09:36 ns kernel: [17180079.172000]  <c02986e6> inet_sendmsg+0x4a/0x56  <c0253256> sock_sendmsg+0xeb/0x105
Aug 26 07:09:36 ns kernel: [17180079.264000]  <c01c18cc> __next_cpu+0x22/0x31  <c01167c7> find_busiest_group+0xd6/0x305
Aug 26 07:09:36 ns kernel: [17180079.364000]  <c01177e6> dependent_sleeper+0x1ec/0x32d  <c012f91e> autoremove_wake_function+0x0/0x57
Aug 26 07:09:36 ns kernel: [17180079.476000]  <c01c662e> copy_from_user+0x46/0x7c  <c01c662e> copy_from_user+0x46/0x7c
Aug 26 07:09:36 ns kernel: [17180079.576000]  <c0254d9d> sys_sendmsg+0x191/0x1f8  <c01334c6> futex_wait+0x129/0x238
Aug 26 07:09:36 ns kernel: [17180079.672000]  <c014b75c> find_extend_vma+0x29/0x7e  <c0117927> default_wake_function+0x0/0x12
Aug 26 07:09:36 ns kernel: [17180079.776000]  <c0132b91> futex_wake+0x4a/0xba  <c01667a8> pipe_write+0x0/0x3b
Aug 26 07:09:36 ns kernel: [17180079.864000]  <c01c662e> copy_from_user+0x46/0x7c  <c0255243> sys_socketcall+0x236/0x254
Aug 26 07:09:36 ns kernel: [17180079.964000]  <c0102be3> syscall_call+0x7/0xb 
Aug 26 07:09:36 ns kernel: [17180080.020000] Code: 24 8b 44 24 34 89 50 04 89 5c 24 0c 8b 4c 24 20 8b 45 1c 89 4c 24 04 89 44 24 08 8b 44 24 54 89 04 24 e8 25 a6 fa ff 85 c0 74 08 <0f> 0b b5 02 21 fb 30 c0 0f b7 44 24 1c 8b 4c 24 34 89 c2 c1 e8 
Aug 26 07:09:36 ns kernel: [17180080.264000] EIP: [ip6_fragment+619/1981] ip6_fragment+0x26b/0x7bd SS:ESP 0068:f71f5bb8
----------------------------------------------------------------------


-- 
cagri
