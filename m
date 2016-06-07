From: Helge Deller <deller@gmx.de>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Tue, 7 Jun 2016 16:13:50 +0200
Message-ID: <5756D69E.1080402@gmx.de>
References: <5751E702.5040909@gmx.de> <20160604073527.GE29740@orbyte.nwl.cc>
 <20160606035718.GA19559@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:53621 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932364AbcFGOOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 10:14:05 -0400
In-Reply-To: <20160606035718.GA19559@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.06.2016 05:57, Herbert Xu wrote:
> On Sat, Jun 04, 2016 at 09:35:27AM +0200, Phil Sutter wrote:
>> [Cc'ing other interested parties, therefore full-quoting.]
>>
>> Hi Helge,
>>
>> On Fri, Jun 03, 2016 at 10:22:26PM +0200, Helge Deller wrote:
>>> Hi Phil,
>>>
>>> I'm testing 4.7.0-rc1-64bit on a parisc/hppa machine and get
>>> those message with CONFIG_TEST_RHASHTABLE=y.
>>>
>>> Is this expected/normal ?
>>
>> No, this shouldn't happen. Can you possibly bisect the issue?
> 
> This reminds me that I do still have to tackle the multi-page
> kmalloc issue.  This may or may not be the problem here.  Enabling
> warnings at the kmalloc call should be an easy way to check.

What warnings do you mean specifically? Some specific CONFIG_ option ?

I enabled a few debug CONFIG options and get:
[    0.000000] parisc_cache_init: Only equivalent aliasing supported!
[    0.000000] Memory Ranges:
[    0.000000]  0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
[    0.000000]  1) Start 0x0000000100000000 End 0x00000001ffdfffff Size   4094 MB
[    0.000000]  2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
[    0.000000] Total Memory: 8190 MB
[    0.000000] percpu: Embedded 14 pages/cpu @0000000043c64000 s19168 r8192 d29984 u57344
[    0.000000] SMP: bootstrap CPU ID is 0
[    0.000000] Built 3 zonelists in Zone order, mobility grouping on.  Total pages: 2067975
[    0.000000] Kernel command line: HOME=/ root=/dev/sda5 pa64_root=sda5 c3k=sda5 c8k_root=sda5 ip=bootp panic_timeout=60 panic=-1 hugepages=100 console=ttyS0 TERM=vt1x
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 126976 bytes
[    0.000000] log_buf_len min size: 131072 bytes
[    0.000000] log_buf_len: 262144 bytes
[    0.000000] early log buf free: 127768(97%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.000000] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] allocated 16781312 bytes of page_ext
[    0.000000] Backtrace:
[    0.000000]  [<0000000040313ef4>] __free_pages+0xdc/0xf0
[    0.000000]  [<0000000040112be4>] 0x40112be4
[    0.000000]  [<0000000040119098>] 0x40119098
[    0.000000]  [<0000000040105594>] 0x40105594
[    0.000000]  [<0000000040101458>] 0x40101458
[    0.000000]  [<0000000040213388>] _raw_spin_trylock+0x0/0x58
[    0.000000] 
[    0.000000] 
[    0.000000] Bad Address (null pointer deref?): Code=15 regs=0000000040e03640 (Addr=80000492b273b000)
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.7.0-rc2-64bit+ #428
[    0.000000] task: 0000000040ef08c0 ti: 0000000040e03000 task.ti: 0000000040e03000
[    0.000000] 
[    0.000000]      YZrvWESTHLNXBCVMcbcbcbcbOGFRQPDI
[    0.000000] PSW: 00001000000001001111101100001110 Not tainted
[    0.000000] r00-03  000000ff0804fb0e 0000000040d62590 0000000040311328 0000000040e03520
[    0.000000] r04-07  0000000040cefd90 0000000000000008 00000001437f2000 0000000000000004
[    0.000000] r08-11  0000000000000000 0000000000000040 0000000000000000 0000000040e10fc0
[    0.000000] r12-15  00000001437f2020 0000000000000001 0000000000000010 00000001437f9000
[    0.000000] r16-19  0000000000007000 00000001437f2000 0000000000000009 0000000000000000
[    0.000000] r20-23  0000000000000001 0000000000000001 0000000000100000 0000000000000cd0
[    0.000000] r24-27  0000000000000000 00000000001ffcc0 924924924db99c00 0000000040cefd90
[    0.000000] r28-31  92492492b273b000 0000000040e03610 0000000040e03640 0000000044a6d000
[    0.000000] sr00-03  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.000000] sr04-07  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.000000] 
[    0.000000] IASQ: 0000000000000000 0000000000000000 IAOQ: 0000000040311330 0000000040311334
[    0.000000]  IIR: 0f8010dc    ISR: 0000000012492000  IOR: 80000492b273b000
[    0.000000]  CPU:        0   CR30: 0000000040e03000 CR31: ffffffffffffffff
[    0.000000]  ORIG_R28: 0000000040cefd90
[    0.000000]  IAOQ[0]: __free_pages_ok+0x9a0/0xd28
[    0.000000]  IAOQ[1]: __free_pages_ok+0x9a4/0xd28
[    0.000000]  RP(r2): __free_pages_ok+0x998/0xd28
[    0.000000] Backtrace:
[    0.000000]  [<0000000040313ef4>] __free_pages+0xdc/0xf0
[    0.000000]  [<0000000040112be4>] 0x40112be4
[    0.000000]  [<0000000040119098>] 0x40119098
[    0.000000]  [<0000000040105594>] 0x40105594
[    0.000000]  [<0000000040101458>] 0x40101458
[    0.000000]  [<0000000040213388>] _raw_spin_trylock+0x0/0x58

Helge
