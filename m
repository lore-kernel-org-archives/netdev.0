From: cagri coltekin <cagri@ripe.net>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Tue, 26 Sep 2006 13:21:22 +0200
Message-ID: <20060926112122.GU22330@ripe.net>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net> <20060925121530.GC18667@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:16320 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S1750770AbWIZLVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 07:21:24 -0400
To: Herbert Xu <herbert.xu@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060925121530.GC18667@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Sep 25, 2006 at 10:15:30PM +1000, Herbert Xu wrote:
> On Fri, Sep 01, 2006 at 06:22:48PM +0200, cagri coltekin wrote:
> >
> > The second causes the system to give the bug a couple of seconds
> > after bind starts, and loads the zones, without any traffic going
> > on. BTW, patch applied with some offset difference (3 for the
> > first -48 for the other two changes), on a pristine 2.6.17.11
> > source tree.
> 
> Well the good news is that I found a bug with MSG_PROBE that can
> cause exactly what you're seeing.  The bad news is that bind doesn't
> use MSG_PROBE :)
> 
> So please try this patch to narrow the problem down further.

This time I applied patch to 2.6.18. The patch applied with some
offset difference. I can stick to a version you suggest if 2.6.18
is not a good. Here is the new bug message:

------------------------------------------------------------------------------
[ 1395.890897] ------------[ cut here ]------------
[ 1395.946093] kernel BUG at net/ipv6/ip6_output.c:940!
[ 1396.005441] invalid opcode: 0000 [#1]
[ 1396.049225] SMP 
[ 1396.071419] Modules linked in: ipmi_si ipmi_msghandler ide_cd cdrom
[ 1396.146853] CPU:    2
[ 1396.146854] EIP:    0060:[<c02c6148>]    Not tainted VLI
[ 1396.146855] EFLAGS: 00010246   (2.6.18-ns-pri-debug-p3 #2) 
[ 1396.304174] EIP is at ip6_append_data+0xaf8/0xbd6
[ 1396.360405] eax: f7534d00   ebx: 00000000   ecx: f7534e9c   edx: f68f4480
[ 1396.441552] esi: f7534ee4   edi: f7534ee4   ebp: f7534ef0   esp: f742bc20
[ 1396.522691] ds: 007b   es: 007b   ss: 0068
[ 1396.571655] Process named (pid: 1897, ti=f742a000 task=c2b2c030 task.ti=f742)
[ 1396.659026] Stack: f68f4480 c03c3cb4 f742bf00 c02ef7e2 c02ce658 c02ce658 c03 
[ 1396.759947]        00000002 c02ef7e2 f7534eb4 f7534d70 00000000 00000000 f74 
[ 1396.860803]        f742bce4 c02c55c5 f7534d00 f7534e9c f7534d00 00000286 f74 
[ 1396.961659] Call Trace:
[ 1396.993128]  [<c02ef7e2>] _read_unlock_bh+0x12/0x16
[ 1397.051544]  [<c02ce658>] ip6_route_output+0xeb/0x1e9
[ 1397.112038]  [<c02ce658>] ip6_route_output+0xeb/0x1e9
[ 1397.172535]  [<c02ef7e2>] _read_unlock_bh+0x12/0x16
[ 1397.230952]  [<c02c55c5>] ip6_dst_lookup_tail+0xc6/0xd0
[ 1397.293524]  [<c02d7e29>] udpv6_sendmsg+0x3d4/0x9ac
[ 1397.351936]  [<c028b4a2>] ip_generic_getfrag+0x0/0xaf
[ 1397.412431]  [<c02d6e22>] udpv6_recvmsg+0x20c/0x303
[ 1397.470846]  [<c02ae7b3>] inet_sendmsg+0x4a/0x56
[ 1397.526148]  [<c02682f4>] sock_sendmsg+0xe8/0x101
[ 1397.582494]  [<c01306ca>] autoremove_wake_function+0x0/0x57
[ 1397.649214]  [<c01cadc4>] copy_from_user+0x46/0x7e
[ 1397.706594]  [<c0269e4b>] sys_sendmsg+0x191/0x1f8
[ 1397.762941]  [<c014fe63>] find_extend_vma+0x29/0x7e
[ 1397.821357]  [<c0133bca>] get_futex_key+0x4c/0x126
[ 1397.878740]  [<c0135be8>] do_futex+0x6c/0x10a
[ 1397.930928]  [<c01cadc4>] copy_from_user+0x46/0x7e
[ 1397.988307]  [<c026a2f1>] sys_socketcall+0x236/0x254
[ 1398.047762]  [<c0102cdf>] syscall_call+0x7/0xb
[ 1398.100989] Code: 34 c7 44 24 04 5a 00 00 00 89 4c 24 0c e8 89 02 02 00 b8 a 
[ 1398.333299] EIP: [<c02c6148>] ip6_append_data+0xaf8/0xbd6 SS:ESP 0068:f742bc0
------------------------------------------------------------------------------

Cheers,
-- 
cagri
