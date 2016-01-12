From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 14/53] perf test: Check environment before start real BPF
 test
Date: Tue, 12 Jan 2016 11:10:13 -0300
Message-ID: <20160112141013.GP18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-15-git-send-email-wangnan0@huawei.com>
 <20160111215503.GJ18367@kernel.org>
 <5694ADF8.3080403@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5694ADF8.3080403@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Jan 12, 2016 at 03:40:40PM +0800, Wangnan (F) escreveu:
> 
> 
> On 2016/1/12 5:55, Arnaldo Carvalho de Melo wrote:
> >Em Mon, Jan 11, 2016 at 01:48:05PM +0000, Wang Nan escreveu:
> >>Copying perf to old kernel system results:
> >>
> >>  # perf test bpf
> >>  37: Test BPF filter                                          :
> >>  37.1: Test basic BPF filtering                               : FAILED!
> >>  37.2: Test BPF prologue generation                           : Skip
> >>
> >>However, in case when kernel doesn't support a test case it should
> >>return 'Skip', 'FAILED!' should be reserved for kernel tests for when
> >>the kernel supports a feature that then fails to work as advertised.
> >>
> >>This patch checks environment before real testcase.
> >This is really strange, this other test is failing if the above patch is
> >present, found by bisecting:
> >
> >[acme@felicio linux]$ perf test decoder
> >47: Test x86 instruction decoder - new instructions          : FAILED!
> >[acme@felicio linux]$ git log --oneline -1
> >91fedd318e3d perf test: Check environment before start real BPF test
> >[acme@felicio linux]$ git reset --hard HEAD^
> >HEAD is now at f1f23526d3b6 perf test: Reset err after using it hold
> >errcode in hist testcases
> >[acme@felicio linux]$ m
> >make: Entering directory `/home/acme/git/linux/tools/perf'
> >   BUILD:   Doing 'make -j4' parallel build
> >   CC       /tmp/build/perf/arch/common.o
> >   CC       /tmp/build/perf/util/abspath.o
> >   CC       /tmp/build/perf/builtin-bench.o
> >   CC       /tmp/build/perf/util/alias.o
> >
> ><SNIP>
> >[acme@felicio linux]$ git log --oneline -1
> >f1f23526d3b6 perf test: Reset err after using it hold errcode in hist
> >testcases
> >[acme@felicio linux]$ perf test decoder
> >47: Test x86 instruction decoder - new instructions          : Ok
> >[acme@felicio linux]$
> 
> Yes, really strange, and I can't reproduce your result
> in my environment. What's the result of test -v?

So, 'the 47: Test x86 instruction decoder' one, without the patch, working,
goes below, I'll send another message with it failing, after I re-apply that patch.


got: test__dwarf_unwind 0x47edbe, expecting test__dwarf_unwind
test child finished with 0
---- end ----
Test dwarf unwind: Ok
47: Test x86 instruction decoder - new instructions          :
--- start ---
test child forked, pid 22923
Decoded ok: 0f 31                	rdtsc  
Decoded ok: f3 0f 1b 00          	bndmk  (%eax),%bnd0
Decoded ok: f3 0f 1b 05 78 56 34 12 	bndmk  0x12345678,%bnd0
Decoded ok: f3 0f 1b 18          	bndmk  (%eax),%bnd3
Decoded ok: f3 0f 1b 04 01       	bndmk  (%ecx,%eax,1),%bnd0
Decoded ok: f3 0f 1b 04 05 78 56 34 12 	bndmk  0x12345678(,%eax,1),%bnd0
Decoded ok: f3 0f 1b 04 08       	bndmk  (%eax,%ecx,1),%bnd0
Decoded ok: f3 0f 1b 04 c8       	bndmk  (%eax,%ecx,8),%bnd0
Decoded ok: f3 0f 1b 40 12       	bndmk  0x12(%eax),%bnd0
Decoded ok: f3 0f 1b 45 12       	bndmk  0x12(%ebp),%bnd0
Decoded ok: f3 0f 1b 44 01 12    	bndmk  0x12(%ecx,%eax,1),%bnd0
Decoded ok: f3 0f 1b 44 05 12    	bndmk  0x12(%ebp,%eax,1),%bnd0
Decoded ok: f3 0f 1b 44 08 12    	bndmk  0x12(%eax,%ecx,1),%bnd0
Decoded ok: f3 0f 1b 44 c8 12    	bndmk  0x12(%eax,%ecx,8),%bnd0
Decoded ok: f3 0f 1b 80 78 56 34 12 	bndmk  0x12345678(%eax),%bnd0
Decoded ok: f3 0f 1b 85 78 56 34 12 	bndmk  0x12345678(%ebp),%bnd0
Decoded ok: f3 0f 1b 84 01 78 56 34 12 	bndmk  0x12345678(%ecx,%eax,1),%bnd0
Decoded ok: f3 0f 1b 84 05 78 56 34 12 	bndmk  0x12345678(%ebp,%eax,1),%bnd0
Decoded ok: f3 0f 1b 84 08 78 56 34 12 	bndmk  0x12345678(%eax,%ecx,1),%bnd0
Decoded ok: f3 0f 1b 84 c8 78 56 34 12 	bndmk  0x12345678(%eax,%ecx,8),%bnd0
Decoded ok: f3 0f 1a 00          	bndcl  (%eax),%bnd0
Decoded ok: f3 0f 1a 05 78 56 34 12 	bndcl  0x12345678,%bnd0
Decoded ok: f3 0f 1a 18          	bndcl  (%eax),%bnd3
Decoded ok: f3 0f 1a 04 01       	bndcl  (%ecx,%eax,1),%bnd0
Decoded ok: f3 0f 1a 04 05 78 56 34 12 	bndcl  0x12345678(,%eax,1),%bnd0
Decoded ok: f3 0f 1a 04 08       	bndcl  (%eax,%ecx,1),%bnd0
Decoded ok: f3 0f 1a 04 c8       	bndcl  (%eax,%ecx,8),%bnd0
Decoded ok: f3 0f 1a 40 12       	bndcl  0x12(%eax),%bnd0
Decoded ok: f3 0f 1a 45 12       	bndcl  0x12(%ebp),%bnd0
Decoded ok: f3 0f 1a 44 01 12    	bndcl  0x12(%ecx,%eax,1),%bnd0
Decoded ok: f3 0f 1a 44 05 12    	bndcl  0x12(%ebp,%eax,1),%bnd0
Decoded ok: f3 0f 1a 44 08 12    	bndcl  0x12(%eax,%ecx,1),%bnd0
Decoded ok: f3 0f 1a 44 c8 12    	bndcl  0x12(%eax,%ecx,8),%bnd0
Decoded ok: f3 0f 1a 80 78 56 34 12 	bndcl  0x12345678(%eax),%bnd0
Decoded ok: f3 0f 1a 85 78 56 34 12 	bndcl  0x12345678(%ebp),%bnd0
Decoded ok: f3 0f 1a 84 01 78 56 34 12 	bndcl  0x12345678(%ecx,%eax,1),%bnd0
Decoded ok: f3 0f 1a 84 05 78 56 34 12 	bndcl  0x12345678(%ebp,%eax,1),%bnd0
Decoded ok: f3 0f 1a 84 08 78 56 34 12 	bndcl  0x12345678(%eax,%ecx,1),%bnd0
Decoded ok: f3 0f 1a 84 c8 78 56 34 12 	bndcl  0x12345678(%eax,%ecx,8),%bnd0
Decoded ok: f3 0f 1a c0          	bndcl  %eax,%bnd0
Decoded ok: f2 0f 1a 00          	bndcu  (%eax),%bnd0
Decoded ok: f2 0f 1a 05 78 56 34 12 	bndcu  0x12345678,%bnd0
Decoded ok: f2 0f 1a 18          	bndcu  (%eax),%bnd3
Decoded ok: f2 0f 1a 04 01       	bndcu  (%ecx,%eax,1),%bnd0
Decoded ok: f2 0f 1a 04 05 78 56 34 12 	bndcu  0x12345678(,%eax,1),%bnd0
Decoded ok: f2 0f 1a 04 08       	bndcu  (%eax,%ecx,1),%bnd0
Decoded ok: f2 0f 1a 04 c8       	bndcu  (%eax,%ecx,8),%bnd0
Decoded ok: f2 0f 1a 40 12       	bndcu  0x12(%eax),%bnd0
Decoded ok: f2 0f 1a 45 12       	bndcu  0x12(%ebp),%bnd0
Decoded ok: f2 0f 1a 44 01 12    	bndcu  0x12(%ecx,%eax,1),%bnd0
Decoded ok: f2 0f 1a 44 05 12    	bndcu  0x12(%ebp,%eax,1),%bnd0
Decoded ok: f2 0f 1a 44 08 12    	bndcu  0x12(%eax,%ecx,1),%bnd0
Decoded ok: f2 0f 1a 44 c8 12    	bndcu  0x12(%eax,%ecx,8),%bnd0
Decoded ok: f2 0f 1a 80 78 56 34 12 	bndcu  0x12345678(%eax),%bnd0
Decoded ok: f2 0f 1a 85 78 56 34 12 	bndcu  0x12345678(%ebp),%bnd0
Decoded ok: f2 0f 1a 84 01 78 56 34 12 	bndcu  0x12345678(%ecx,%eax,1),%bnd0
Decoded ok: f2 0f 1a 84 05 78 56 34 12 	bndcu  0x12345678(%ebp,%eax,1),%bnd0
Decoded ok: f2 0f 1a 84 08 78 56 34 12 	bndcu  0x12345678(%eax,%ecx,1),%bnd0
Decoded ok: f2 0f 1a 84 c8 78 56 34 12 	bndcu  0x12345678(%eax,%ecx,8),%bnd0
Decoded ok: f2 0f 1a c0          	bndcu  %eax,%bnd0
Decoded ok: f2 0f 1b 00          	bndcn  (%eax),%bnd0
Decoded ok: f2 0f 1b 05 78 56 34 12 	bndcn  0x12345678,%bnd0
Decoded ok: f2 0f 1b 18          	bndcn  (%eax),%bnd3
Decoded ok: f2 0f 1b 04 01       	bndcn  (%ecx,%eax,1),%bnd0
Decoded ok: f2 0f 1b 04 05 78 56 34 12 	bndcn  0x12345678(,%eax,1),%bnd0
Decoded ok: f2 0f 1b 04 08       	bndcn  (%eax,%ecx,1),%bnd0
Decoded ok: f2 0f 1b 04 c8       	bndcn  (%eax,%ecx,8),%bnd0
Decoded ok: f2 0f 1b 40 12       	bndcn  0x12(%eax),%bnd0
Decoded ok: f2 0f 1b 45 12       	bndcn  0x12(%ebp),%bnd0
Decoded ok: f2 0f 1b 44 01 12    	bndcn  0x12(%ecx,%eax,1),%bnd0
Decoded ok: f2 0f 1b 44 05 12    	bndcn  0x12(%ebp,%eax,1),%bnd0
Decoded ok: f2 0f 1b 44 08 12    	bndcn  0x12(%eax,%ecx,1),%bnd0
Decoded ok: f2 0f 1b 44 c8 12    	bndcn  0x12(%eax,%ecx,8),%bnd0
Decoded ok: f2 0f 1b 80 78 56 34 12 	bndcn  0x12345678(%eax),%bnd0
Decoded ok: f2 0f 1b 85 78 56 34 12 	bndcn  0x12345678(%ebp),%bnd0
Decoded ok: f2 0f 1b 84 01 78 56 34 12 	bndcn  0x12345678(%ecx,%eax,1),%bnd0
Decoded ok: f2 0f 1b 84 05 78 56 34 12 	bndcn  0x12345678(%ebp,%eax,1),%bnd0
Decoded ok: f2 0f 1b 84 08 78 56 34 12 	bndcn  0x12345678(%eax,%ecx,1),%bnd0
Decoded ok: f2 0f 1b 84 c8 78 56 34 12 	bndcn  0x12345678(%eax,%ecx,8),%bnd0
Decoded ok: f2 0f 1b c0          	bndcn  %eax,%bnd0
Decoded ok: 66 0f 1a 00          	bndmov (%eax),%bnd0
Decoded ok: 66 0f 1a 05 78 56 34 12 	bndmov 0x12345678,%bnd0
Decoded ok: 66 0f 1a 18          	bndmov (%eax),%bnd3
Decoded ok: 66 0f 1a 04 01       	bndmov (%ecx,%eax,1),%bnd0
Decoded ok: 66 0f 1a 04 05 78 56 34 12 	bndmov 0x12345678(,%eax,1),%bnd0
Decoded ok: 66 0f 1a 04 08       	bndmov (%eax,%ecx,1),%bnd0
Decoded ok: 66 0f 1a 04 c8       	bndmov (%eax,%ecx,8),%bnd0
Decoded ok: 66 0f 1a 40 12       	bndmov 0x12(%eax),%bnd0
Decoded ok: 66 0f 1a 45 12       	bndmov 0x12(%ebp),%bnd0
Decoded ok: 66 0f 1a 44 01 12    	bndmov 0x12(%ecx,%eax,1),%bnd0
Decoded ok: 66 0f 1a 44 05 12    	bndmov 0x12(%ebp,%eax,1),%bnd0
Decoded ok: 66 0f 1a 44 08 12    	bndmov 0x12(%eax,%ecx,1),%bnd0
Decoded ok: 66 0f 1a 44 c8 12    	bndmov 0x12(%eax,%ecx,8),%bnd0
Decoded ok: 66 0f 1a 80 78 56 34 12 	bndmov 0x12345678(%eax),%bnd0
Decoded ok: 66 0f 1a 85 78 56 34 12 	bndmov 0x12345678(%ebp),%bnd0
Decoded ok: 66 0f 1a 84 01 78 56 34 12 	bndmov 0x12345678(%ecx,%eax,1),%bnd0
Decoded ok: 66 0f 1a 84 05 78 56 34 12 	bndmov 0x12345678(%ebp,%eax,1),%bnd0
Decoded ok: 66 0f 1a 84 08 78 56 34 12 	bndmov 0x12345678(%eax,%ecx,1),%bnd0
Decoded ok: 66 0f 1a 84 c8 78 56 34 12 	bndmov 0x12345678(%eax,%ecx,8),%bnd0
Decoded ok: 66 0f 1b 00          	bndmov %bnd0,(%eax)
Decoded ok: 66 0f 1b 05 78 56 34 12 	bndmov %bnd0,0x12345678
Decoded ok: 66 0f 1b 18          	bndmov %bnd3,(%eax)
Decoded ok: 66 0f 1b 04 01       	bndmov %bnd0,(%ecx,%eax,1)
Decoded ok: 66 0f 1b 04 05 78 56 34 12 	bndmov %bnd0,0x12345678(,%eax,1)
Decoded ok: 66 0f 1b 04 08       	bndmov %bnd0,(%eax,%ecx,1)
Decoded ok: 66 0f 1b 04 c8       	bndmov %bnd0,(%eax,%ecx,8)
Decoded ok: 66 0f 1b 40 12       	bndmov %bnd0,0x12(%eax)
Decoded ok: 66 0f 1b 45 12       	bndmov %bnd0,0x12(%ebp)
Decoded ok: 66 0f 1b 44 01 12    	bndmov %bnd0,0x12(%ecx,%eax,1)
Decoded ok: 66 0f 1b 44 05 12    	bndmov %bnd0,0x12(%ebp,%eax,1)
Decoded ok: 66 0f 1b 44 08 12    	bndmov %bnd0,0x12(%eax,%ecx,1)
Decoded ok: 66 0f 1b 44 c8 12    	bndmov %bnd0,0x12(%eax,%ecx,8)
Decoded ok: 66 0f 1b 80 78 56 34 12 	bndmov %bnd0,0x12345678(%eax)
Decoded ok: 66 0f 1b 85 78 56 34 12 	bndmov %bnd0,0x12345678(%ebp)
Decoded ok: 66 0f 1b 84 01 78 56 34 12 	bndmov %bnd0,0x12345678(%ecx,%eax,1)
Decoded ok: 66 0f 1b 84 05 78 56 34 12 	bndmov %bnd0,0x12345678(%ebp,%eax,1)
Decoded ok: 66 0f 1b 84 08 78 56 34 12 	bndmov %bnd0,0x12345678(%eax,%ecx,1)
Decoded ok: 66 0f 1b 84 c8 78 56 34 12 	bndmov %bnd0,0x12345678(%eax,%ecx,8)
Decoded ok: 66 0f 1a c8          	bndmov %bnd0,%bnd1
Decoded ok: 66 0f 1a c1          	bndmov %bnd1,%bnd0
Decoded ok: 0f 1a 00             	bndldx (%eax),%bnd0
Decoded ok: 0f 1a 05 78 56 34 12 	bndldx 0x12345678,%bnd0
Decoded ok: 0f 1a 18             	bndldx (%eax),%bnd3
Decoded ok: 0f 1a 04 01          	bndldx (%ecx,%eax,1),%bnd0
Decoded ok: 0f 1a 04 05 78 56 34 12 	bndldx 0x12345678(,%eax,1),%bnd0
Decoded ok: 0f 1a 04 08          	bndldx (%eax,%ecx,1),%bnd0
Decoded ok: 0f 1a 40 12          	bndldx 0x12(%eax),%bnd0
Decoded ok: 0f 1a 45 12          	bndldx 0x12(%ebp),%bnd0
Decoded ok: 0f 1a 44 01 12       	bndldx 0x12(%ecx,%eax,1),%bnd0
Decoded ok: 0f 1a 44 05 12       	bndldx 0x12(%ebp,%eax,1),%bnd0
Decoded ok: 0f 1a 44 08 12       	bndldx 0x12(%eax,%ecx,1),%bnd0
Decoded ok: 0f 1a 80 78 56 34 12 	bndldx 0x12345678(%eax),%bnd0
Decoded ok: 0f 1a 85 78 56 34 12 	bndldx 0x12345678(%ebp),%bnd0
Decoded ok: 0f 1a 84 01 78 56 34 12 	bndldx 0x12345678(%ecx,%eax,1),%bnd0
Decoded ok: 0f 1a 84 05 78 56 34 12 	bndldx 0x12345678(%ebp,%eax,1),%bnd0
Decoded ok: 0f 1a 84 08 78 56 34 12 	bndldx 0x12345678(%eax,%ecx,1),%bnd0
Decoded ok: 0f 1b 00             	bndstx %bnd0,(%eax)
Decoded ok: 0f 1b 05 78 56 34 12 	bndstx %bnd0,0x12345678
Decoded ok: 0f 1b 18             	bndstx %bnd3,(%eax)
Decoded ok: 0f 1b 04 01          	bndstx %bnd0,(%ecx,%eax,1)
Decoded ok: 0f 1b 04 05 78 56 34 12 	bndstx %bnd0,0x12345678(,%eax,1)
Decoded ok: 0f 1b 04 08          	bndstx %bnd0,(%eax,%ecx,1)
Decoded ok: 0f 1b 40 12          	bndstx %bnd0,0x12(%eax)
Decoded ok: 0f 1b 45 12          	bndstx %bnd0,0x12(%ebp)
Decoded ok: 0f 1b 44 01 12       	bndstx %bnd0,0x12(%ecx,%eax,1)
Decoded ok: 0f 1b 44 05 12       	bndstx %bnd0,0x12(%ebp,%eax,1)
Decoded ok: 0f 1b 44 08 12       	bndstx %bnd0,0x12(%eax,%ecx,1)
Decoded ok: 0f 1b 80 78 56 34 12 	bndstx %bnd0,0x12345678(%eax)
Decoded ok: 0f 1b 85 78 56 34 12 	bndstx %bnd0,0x12345678(%ebp)
Decoded ok: 0f 1b 84 01 78 56 34 12 	bndstx %bnd0,0x12345678(%ecx,%eax,1)
Decoded ok: 0f 1b 84 05 78 56 34 12 	bndstx %bnd0,0x12345678(%ebp,%eax,1)
Decoded ok: 0f 1b 84 08 78 56 34 12 	bndstx %bnd0,0x12345678(%eax,%ecx,1)
Decoded ok: f2 e8 fc ff ff ff    	bnd call 3c3 <main+0x3c3>
Decoded ok: f2 ff 10             	bnd call *(%eax)
Decoded ok: f2 c3                	bnd ret 
Decoded ok: f2 e9 fc ff ff ff    	bnd jmp 3ce <main+0x3ce>
Decoded ok: f2 e9 fc ff ff ff    	bnd jmp 3d4 <main+0x3d4>
Decoded ok: f2 ff 21             	bnd jmp *(%ecx)
Decoded ok: f2 0f 85 fc ff ff ff 	bnd jne 3de <main+0x3de>
Decoded ok: 0f 3a cc c1 00       	sha1rnds4 $0x0,%xmm1,%xmm0
Decoded ok: 0f 3a cc d7 91       	sha1rnds4 $0x91,%xmm7,%xmm2
Decoded ok: 0f 3a cc 00 91       	sha1rnds4 $0x91,(%eax),%xmm0
Decoded ok: 0f 3a cc 05 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678,%xmm0
Decoded ok: 0f 3a cc 18 91       	sha1rnds4 $0x91,(%eax),%xmm3
Decoded ok: 0f 3a cc 04 01 91    	sha1rnds4 $0x91,(%ecx,%eax,1),%xmm0
Decoded ok: 0f 3a cc 04 05 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(,%eax,1),%xmm0
Decoded ok: 0f 3a cc 04 08 91    	sha1rnds4 $0x91,(%eax,%ecx,1),%xmm0
Decoded ok: 0f 3a cc 04 c8 91    	sha1rnds4 $0x91,(%eax,%ecx,8),%xmm0
Decoded ok: 0f 3a cc 40 12 91    	sha1rnds4 $0x91,0x12(%eax),%xmm0
Decoded ok: 0f 3a cc 45 12 91    	sha1rnds4 $0x91,0x12(%ebp),%xmm0
Decoded ok: 0f 3a cc 44 01 12 91 	sha1rnds4 $0x91,0x12(%ecx,%eax,1),%xmm0
Decoded ok: 0f 3a cc 44 05 12 91 	sha1rnds4 $0x91,0x12(%ebp,%eax,1),%xmm0
Decoded ok: 0f 3a cc 44 08 12 91 	sha1rnds4 $0x91,0x12(%eax,%ecx,1),%xmm0
Decoded ok: 0f 3a cc 44 c8 12 91 	sha1rnds4 $0x91,0x12(%eax,%ecx,8),%xmm0
Decoded ok: 0f 3a cc 80 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%eax),%xmm0
Decoded ok: 0f 3a cc 85 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%ebp),%xmm0
Decoded ok: 0f 3a cc 84 01 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%ecx,%eax,1),%xmm0
Decoded ok: 0f 3a cc 84 05 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%ebp,%eax,1),%xmm0
Decoded ok: 0f 3a cc 84 08 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%eax,%ecx,1),%xmm0
Decoded ok: 0f 3a cc 84 c8 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 c8 c1          	sha1nexte %xmm1,%xmm0
Decoded ok: 0f 38 c8 d7          	sha1nexte %xmm7,%xmm2
Decoded ok: 0f 38 c8 00          	sha1nexte (%eax),%xmm0
Decoded ok: 0f 38 c8 05 78 56 34 12 	sha1nexte 0x12345678,%xmm0
Decoded ok: 0f 38 c8 18          	sha1nexte (%eax),%xmm3
Decoded ok: 0f 38 c8 04 01       	sha1nexte (%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 c8 04 05 78 56 34 12 	sha1nexte 0x12345678(,%eax,1),%xmm0
Decoded ok: 0f 38 c8 04 08       	sha1nexte (%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 c8 04 c8       	sha1nexte (%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 c8 40 12       	sha1nexte 0x12(%eax),%xmm0
Decoded ok: 0f 38 c8 45 12       	sha1nexte 0x12(%ebp),%xmm0
Decoded ok: 0f 38 c8 44 01 12    	sha1nexte 0x12(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 c8 44 05 12    	sha1nexte 0x12(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 c8 44 08 12    	sha1nexte 0x12(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 c8 44 c8 12    	sha1nexte 0x12(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 c8 80 78 56 34 12 	sha1nexte 0x12345678(%eax),%xmm0
Decoded ok: 0f 38 c8 85 78 56 34 12 	sha1nexte 0x12345678(%ebp),%xmm0
Decoded ok: 0f 38 c8 84 01 78 56 34 12 	sha1nexte 0x12345678(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 c8 84 05 78 56 34 12 	sha1nexte 0x12345678(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 c8 84 08 78 56 34 12 	sha1nexte 0x12345678(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 c8 84 c8 78 56 34 12 	sha1nexte 0x12345678(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 c9 c1          	sha1msg1 %xmm1,%xmm0
Decoded ok: 0f 38 c9 d7          	sha1msg1 %xmm7,%xmm2
Decoded ok: 0f 38 c9 00          	sha1msg1 (%eax),%xmm0
Decoded ok: 0f 38 c9 05 78 56 34 12 	sha1msg1 0x12345678,%xmm0
Decoded ok: 0f 38 c9 18          	sha1msg1 (%eax),%xmm3
Decoded ok: 0f 38 c9 04 01       	sha1msg1 (%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 c9 04 05 78 56 34 12 	sha1msg1 0x12345678(,%eax,1),%xmm0
Decoded ok: 0f 38 c9 04 08       	sha1msg1 (%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 c9 04 c8       	sha1msg1 (%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 c9 40 12       	sha1msg1 0x12(%eax),%xmm0
Decoded ok: 0f 38 c9 45 12       	sha1msg1 0x12(%ebp),%xmm0
Decoded ok: 0f 38 c9 44 01 12    	sha1msg1 0x12(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 c9 44 05 12    	sha1msg1 0x12(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 c9 44 08 12    	sha1msg1 0x12(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 c9 44 c8 12    	sha1msg1 0x12(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 c9 80 78 56 34 12 	sha1msg1 0x12345678(%eax),%xmm0
Decoded ok: 0f 38 c9 85 78 56 34 12 	sha1msg1 0x12345678(%ebp),%xmm0
Decoded ok: 0f 38 c9 84 01 78 56 34 12 	sha1msg1 0x12345678(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 c9 84 05 78 56 34 12 	sha1msg1 0x12345678(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 c9 84 08 78 56 34 12 	sha1msg1 0x12345678(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 c9 84 c8 78 56 34 12 	sha1msg1 0x12345678(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 ca c1          	sha1msg2 %xmm1,%xmm0
Decoded ok: 0f 38 ca d7          	sha1msg2 %xmm7,%xmm2
Decoded ok: 0f 38 ca 00          	sha1msg2 (%eax),%xmm0
Decoded ok: 0f 38 ca 05 78 56 34 12 	sha1msg2 0x12345678,%xmm0
Decoded ok: 0f 38 ca 18          	sha1msg2 (%eax),%xmm3
Decoded ok: 0f 38 ca 04 01       	sha1msg2 (%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 ca 04 05 78 56 34 12 	sha1msg2 0x12345678(,%eax,1),%xmm0
Decoded ok: 0f 38 ca 04 08       	sha1msg2 (%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 ca 04 c8       	sha1msg2 (%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 ca 40 12       	sha1msg2 0x12(%eax),%xmm0
Decoded ok: 0f 38 ca 45 12       	sha1msg2 0x12(%ebp),%xmm0
Decoded ok: 0f 38 ca 44 01 12    	sha1msg2 0x12(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 ca 44 05 12    	sha1msg2 0x12(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 ca 44 08 12    	sha1msg2 0x12(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 ca 44 c8 12    	sha1msg2 0x12(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 ca 80 78 56 34 12 	sha1msg2 0x12345678(%eax),%xmm0
Decoded ok: 0f 38 ca 85 78 56 34 12 	sha1msg2 0x12345678(%ebp),%xmm0
Decoded ok: 0f 38 ca 84 01 78 56 34 12 	sha1msg2 0x12345678(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 ca 84 05 78 56 34 12 	sha1msg2 0x12345678(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 ca 84 08 78 56 34 12 	sha1msg2 0x12345678(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 ca 84 c8 78 56 34 12 	sha1msg2 0x12345678(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 cb cc          	sha256rnds2 %xmm0,%xmm4,%xmm1
Decoded ok: 0f 38 cb d7          	sha256rnds2 %xmm0,%xmm7,%xmm2
Decoded ok: 0f 38 cb 08          	sha256rnds2 %xmm0,(%eax),%xmm1
Decoded ok: 0f 38 cb 0d 78 56 34 12 	sha256rnds2 %xmm0,0x12345678,%xmm1
Decoded ok: 0f 38 cb 18          	sha256rnds2 %xmm0,(%eax),%xmm3
Decoded ok: 0f 38 cb 0c 01       	sha256rnds2 %xmm0,(%ecx,%eax,1),%xmm1
Decoded ok: 0f 38 cb 0c 05 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(,%eax,1),%xmm1
Decoded ok: 0f 38 cb 0c 08       	sha256rnds2 %xmm0,(%eax,%ecx,1),%xmm1
Decoded ok: 0f 38 cb 0c c8       	sha256rnds2 %xmm0,(%eax,%ecx,8),%xmm1
Decoded ok: 0f 38 cb 48 12       	sha256rnds2 %xmm0,0x12(%eax),%xmm1
Decoded ok: 0f 38 cb 4d 12       	sha256rnds2 %xmm0,0x12(%ebp),%xmm1
Decoded ok: 0f 38 cb 4c 01 12    	sha256rnds2 %xmm0,0x12(%ecx,%eax,1),%xmm1
Decoded ok: 0f 38 cb 4c 05 12    	sha256rnds2 %xmm0,0x12(%ebp,%eax,1),%xmm1
Decoded ok: 0f 38 cb 4c 08 12    	sha256rnds2 %xmm0,0x12(%eax,%ecx,1),%xmm1
Decoded ok: 0f 38 cb 4c c8 12    	sha256rnds2 %xmm0,0x12(%eax,%ecx,8),%xmm1
Decoded ok: 0f 38 cb 88 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%eax),%xmm1
Decoded ok: 0f 38 cb 8d 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%ebp),%xmm1
Decoded ok: 0f 38 cb 8c 01 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%ecx,%eax,1),%xmm1
Decoded ok: 0f 38 cb 8c 05 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%ebp,%eax,1),%xmm1
Decoded ok: 0f 38 cb 8c 08 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%eax,%ecx,1),%xmm1
Decoded ok: 0f 38 cb 8c c8 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%eax,%ecx,8),%xmm1
Decoded ok: 0f 38 cc c1          	sha256msg1 %xmm1,%xmm0
Decoded ok: 0f 38 cc d7          	sha256msg1 %xmm7,%xmm2
Decoded ok: 0f 38 cc 00          	sha256msg1 (%eax),%xmm0
Decoded ok: 0f 38 cc 05 78 56 34 12 	sha256msg1 0x12345678,%xmm0
Decoded ok: 0f 38 cc 18          	sha256msg1 (%eax),%xmm3
Decoded ok: 0f 38 cc 04 01       	sha256msg1 (%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 cc 04 05 78 56 34 12 	sha256msg1 0x12345678(,%eax,1),%xmm0
Decoded ok: 0f 38 cc 04 08       	sha256msg1 (%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 cc 04 c8       	sha256msg1 (%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 cc 40 12       	sha256msg1 0x12(%eax),%xmm0
Decoded ok: 0f 38 cc 45 12       	sha256msg1 0x12(%ebp),%xmm0
Decoded ok: 0f 38 cc 44 01 12    	sha256msg1 0x12(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 cc 44 05 12    	sha256msg1 0x12(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 cc 44 08 12    	sha256msg1 0x12(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 cc 44 c8 12    	sha256msg1 0x12(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 cc 80 78 56 34 12 	sha256msg1 0x12345678(%eax),%xmm0
Decoded ok: 0f 38 cc 85 78 56 34 12 	sha256msg1 0x12345678(%ebp),%xmm0
Decoded ok: 0f 38 cc 84 01 78 56 34 12 	sha256msg1 0x12345678(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 cc 84 05 78 56 34 12 	sha256msg1 0x12345678(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 cc 84 08 78 56 34 12 	sha256msg1 0x12345678(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 cc 84 c8 78 56 34 12 	sha256msg1 0x12345678(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 cd c1          	sha256msg2 %xmm1,%xmm0
Decoded ok: 0f 38 cd d7          	sha256msg2 %xmm7,%xmm2
Decoded ok: 0f 38 cd 00          	sha256msg2 (%eax),%xmm0
Decoded ok: 0f 38 cd 05 78 56 34 12 	sha256msg2 0x12345678,%xmm0
Decoded ok: 0f 38 cd 18          	sha256msg2 (%eax),%xmm3
Decoded ok: 0f 38 cd 04 01       	sha256msg2 (%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 cd 04 05 78 56 34 12 	sha256msg2 0x12345678(,%eax,1),%xmm0
Decoded ok: 0f 38 cd 04 08       	sha256msg2 (%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 cd 04 c8       	sha256msg2 (%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 cd 40 12       	sha256msg2 0x12(%eax),%xmm0
Decoded ok: 0f 38 cd 45 12       	sha256msg2 0x12(%ebp),%xmm0
Decoded ok: 0f 38 cd 44 01 12    	sha256msg2 0x12(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 cd 44 05 12    	sha256msg2 0x12(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 cd 44 08 12    	sha256msg2 0x12(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 cd 44 c8 12    	sha256msg2 0x12(%eax,%ecx,8),%xmm0
Decoded ok: 0f 38 cd 80 78 56 34 12 	sha256msg2 0x12345678(%eax),%xmm0
Decoded ok: 0f 38 cd 85 78 56 34 12 	sha256msg2 0x12345678(%ebp),%xmm0
Decoded ok: 0f 38 cd 84 01 78 56 34 12 	sha256msg2 0x12345678(%ecx,%eax,1),%xmm0
Decoded ok: 0f 38 cd 84 05 78 56 34 12 	sha256msg2 0x12345678(%ebp,%eax,1),%xmm0
Decoded ok: 0f 38 cd 84 08 78 56 34 12 	sha256msg2 0x12345678(%eax,%ecx,1),%xmm0
Decoded ok: 0f 38 cd 84 c8 78 56 34 12 	sha256msg2 0x12345678(%eax,%ecx,8),%xmm0
Decoded ok: 66 0f ae 38          	clflushopt (%eax)
Decoded ok: 66 0f ae 3d 78 56 34 12 	clflushopt 0x12345678
Decoded ok: 66 0f ae bc c8 78 56 34 12 	clflushopt 0x12345678(%eax,%ecx,8)
Decoded ok: 0f ae 38             	clflush (%eax)
Decoded ok: 0f ae f8             	sfence 
Decoded ok: 66 0f ae 30          	clwb   (%eax)
Decoded ok: 66 0f ae 35 78 56 34 12 	clwb   0x12345678
Decoded ok: 66 0f ae b4 c8 78 56 34 12 	clwb   0x12345678(%eax,%ecx,8)
Decoded ok: 0f ae 30             	xsaveopt (%eax)
Decoded ok: 0f ae f0             	mfence 
Decoded ok: 0f c7 20             	xsavec (%eax)
Decoded ok: 0f c7 25 78 56 34 12 	xsavec 0x12345678
Decoded ok: 0f c7 a4 c8 78 56 34 12 	xsavec 0x12345678(%eax,%ecx,8)
Decoded ok: 0f c7 28             	xsaves (%eax)
Decoded ok: 0f c7 2d 78 56 34 12 	xsaves 0x12345678
Decoded ok: 0f c7 ac c8 78 56 34 12 	xsaves 0x12345678(%eax,%ecx,8)
Decoded ok: 0f c7 18             	xrstors (%eax)
Decoded ok: 0f c7 1d 78 56 34 12 	xrstors 0x12345678
Decoded ok: 0f c7 9c c8 78 56 34 12 	xrstors 0x12345678(%eax,%ecx,8)
Decoded ok: 66 0f ae f8          	pcommit 
Decoded ok: 0f 01 ee             	rdpkru
Decoded ok: 0f 01 ef             	wrpkru
Decoded ok: 0f 31                	rdtsc  
Decoded ok: f3 0f 1b 00          	bndmk  (%rax),%bnd0
Decoded ok: f3 41 0f 1b 00       	bndmk  (%r8),%bnd0
Decoded ok: f3 0f 1b 04 25 78 56 34 12 	bndmk  0x12345678,%bnd0
Decoded ok: f3 0f 1b 18          	bndmk  (%rax),%bnd3
Decoded ok: f3 0f 1b 04 01       	bndmk  (%rcx,%rax,1),%bnd0
Decoded ok: f3 0f 1b 04 05 78 56 34 12 	bndmk  0x12345678(,%rax,1),%bnd0
Decoded ok: f3 0f 1b 04 08       	bndmk  (%rax,%rcx,1),%bnd0
Decoded ok: f3 0f 1b 04 c8       	bndmk  (%rax,%rcx,8),%bnd0
Decoded ok: f3 0f 1b 40 12       	bndmk  0x12(%rax),%bnd0
Decoded ok: f3 0f 1b 45 12       	bndmk  0x12(%rbp),%bnd0
Decoded ok: f3 0f 1b 44 01 12    	bndmk  0x12(%rcx,%rax,1),%bnd0
Decoded ok: f3 0f 1b 44 05 12    	bndmk  0x12(%rbp,%rax,1),%bnd0
Decoded ok: f3 0f 1b 44 08 12    	bndmk  0x12(%rax,%rcx,1),%bnd0
Decoded ok: f3 0f 1b 44 c8 12    	bndmk  0x12(%rax,%rcx,8),%bnd0
Decoded ok: f3 0f 1b 80 78 56 34 12 	bndmk  0x12345678(%rax),%bnd0
Decoded ok: f3 0f 1b 85 78 56 34 12 	bndmk  0x12345678(%rbp),%bnd0
Decoded ok: f3 0f 1b 84 01 78 56 34 12 	bndmk  0x12345678(%rcx,%rax,1),%bnd0
Decoded ok: f3 0f 1b 84 05 78 56 34 12 	bndmk  0x12345678(%rbp,%rax,1),%bnd0
Decoded ok: f3 0f 1b 84 08 78 56 34 12 	bndmk  0x12345678(%rax,%rcx,1),%bnd0
Decoded ok: f3 0f 1b 84 c8 78 56 34 12 	bndmk  0x12345678(%rax,%rcx,8),%bnd0
Decoded ok: f3 0f 1a 00          	bndcl  (%rax),%bnd0
Decoded ok: f3 41 0f 1a 00       	bndcl  (%r8),%bnd0
Decoded ok: f3 0f 1a 04 25 78 56 34 12 	bndcl  0x12345678,%bnd0
Decoded ok: f3 0f 1a 18          	bndcl  (%rax),%bnd3
Decoded ok: f3 0f 1a 04 01       	bndcl  (%rcx,%rax,1),%bnd0
Decoded ok: f3 0f 1a 04 05 78 56 34 12 	bndcl  0x12345678(,%rax,1),%bnd0
Decoded ok: f3 0f 1a 04 08       	bndcl  (%rax,%rcx,1),%bnd0
Decoded ok: f3 0f 1a 04 c8       	bndcl  (%rax,%rcx,8),%bnd0
Decoded ok: f3 0f 1a 40 12       	bndcl  0x12(%rax),%bnd0
Decoded ok: f3 0f 1a 45 12       	bndcl  0x12(%rbp),%bnd0
Decoded ok: f3 0f 1a 44 01 12    	bndcl  0x12(%rcx,%rax,1),%bnd0
Decoded ok: f3 0f 1a 44 05 12    	bndcl  0x12(%rbp,%rax,1),%bnd0
Decoded ok: f3 0f 1a 44 08 12    	bndcl  0x12(%rax,%rcx,1),%bnd0
Decoded ok: f3 0f 1a 44 c8 12    	bndcl  0x12(%rax,%rcx,8),%bnd0
Decoded ok: f3 0f 1a 80 78 56 34 12 	bndcl  0x12345678(%rax),%bnd0
Decoded ok: f3 0f 1a 85 78 56 34 12 	bndcl  0x12345678(%rbp),%bnd0
Decoded ok: f3 0f 1a 84 01 78 56 34 12 	bndcl  0x12345678(%rcx,%rax,1),%bnd0
Decoded ok: f3 0f 1a 84 05 78 56 34 12 	bndcl  0x12345678(%rbp,%rax,1),%bnd0
Decoded ok: f3 0f 1a 84 08 78 56 34 12 	bndcl  0x12345678(%rax,%rcx,1),%bnd0
Decoded ok: f3 0f 1a 84 c8 78 56 34 12 	bndcl  0x12345678(%rax,%rcx,8),%bnd0
Decoded ok: f3 0f 1a c0          	bndcl  %rax,%bnd0
Decoded ok: f2 0f 1a 00          	bndcu  (%rax),%bnd0
Decoded ok: f2 41 0f 1a 00       	bndcu  (%r8),%bnd0
Decoded ok: f2 0f 1a 04 25 78 56 34 12 	bndcu  0x12345678,%bnd0
Decoded ok: f2 0f 1a 18          	bndcu  (%rax),%bnd3
Decoded ok: f2 0f 1a 04 01       	bndcu  (%rcx,%rax,1),%bnd0
Decoded ok: f2 0f 1a 04 05 78 56 34 12 	bndcu  0x12345678(,%rax,1),%bnd0
Decoded ok: f2 0f 1a 04 08       	bndcu  (%rax,%rcx,1),%bnd0
Decoded ok: f2 0f 1a 04 c8       	bndcu  (%rax,%rcx,8),%bnd0
Decoded ok: f2 0f 1a 40 12       	bndcu  0x12(%rax),%bnd0
Decoded ok: f2 0f 1a 45 12       	bndcu  0x12(%rbp),%bnd0
Decoded ok: f2 0f 1a 44 01 12    	bndcu  0x12(%rcx,%rax,1),%bnd0
Decoded ok: f2 0f 1a 44 05 12    	bndcu  0x12(%rbp,%rax,1),%bnd0
Decoded ok: f2 0f 1a 44 08 12    	bndcu  0x12(%rax,%rcx,1),%bnd0
Decoded ok: f2 0f 1a 44 c8 12    	bndcu  0x12(%rax,%rcx,8),%bnd0
Decoded ok: f2 0f 1a 80 78 56 34 12 	bndcu  0x12345678(%rax),%bnd0
Decoded ok: f2 0f 1a 85 78 56 34 12 	bndcu  0x12345678(%rbp),%bnd0
Decoded ok: f2 0f 1a 84 01 78 56 34 12 	bndcu  0x12345678(%rcx,%rax,1),%bnd0
Decoded ok: f2 0f 1a 84 05 78 56 34 12 	bndcu  0x12345678(%rbp,%rax,1),%bnd0
Decoded ok: f2 0f 1a 84 08 78 56 34 12 	bndcu  0x12345678(%rax,%rcx,1),%bnd0
Decoded ok: f2 0f 1a 84 c8 78 56 34 12 	bndcu  0x12345678(%rax,%rcx,8),%bnd0
Decoded ok: f2 0f 1a c0          	bndcu  %rax,%bnd0
Decoded ok: f2 0f 1b 00          	bndcn  (%rax),%bnd0
Decoded ok: f2 41 0f 1b 00       	bndcn  (%r8),%bnd0
Decoded ok: f2 0f 1b 04 25 78 56 34 12 	bndcn  0x12345678,%bnd0
Decoded ok: f2 0f 1b 18          	bndcn  (%rax),%bnd3
Decoded ok: f2 0f 1b 04 01       	bndcn  (%rcx,%rax,1),%bnd0
Decoded ok: f2 0f 1b 04 05 78 56 34 12 	bndcn  0x12345678(,%rax,1),%bnd0
Decoded ok: f2 0f 1b 04 08       	bndcn  (%rax,%rcx,1),%bnd0
Decoded ok: f2 0f 1b 04 c8       	bndcn  (%rax,%rcx,8),%bnd0
Decoded ok: f2 0f 1b 40 12       	bndcn  0x12(%rax),%bnd0
Decoded ok: f2 0f 1b 45 12       	bndcn  0x12(%rbp),%bnd0
Decoded ok: f2 0f 1b 44 01 12    	bndcn  0x12(%rcx,%rax,1),%bnd0
Decoded ok: f2 0f 1b 44 05 12    	bndcn  0x12(%rbp,%rax,1),%bnd0
Decoded ok: f2 0f 1b 44 08 12    	bndcn  0x12(%rax,%rcx,1),%bnd0
Decoded ok: f2 0f 1b 44 c8 12    	bndcn  0x12(%rax,%rcx,8),%bnd0
Decoded ok: f2 0f 1b 80 78 56 34 12 	bndcn  0x12345678(%rax),%bnd0
Decoded ok: f2 0f 1b 85 78 56 34 12 	bndcn  0x12345678(%rbp),%bnd0
Decoded ok: f2 0f 1b 84 01 78 56 34 12 	bndcn  0x12345678(%rcx,%rax,1),%bnd0
Decoded ok: f2 0f 1b 84 05 78 56 34 12 	bndcn  0x12345678(%rbp,%rax,1),%bnd0
Decoded ok: f2 0f 1b 84 08 78 56 34 12 	bndcn  0x12345678(%rax,%rcx,1),%bnd0
Decoded ok: f2 0f 1b 84 c8 78 56 34 12 	bndcn  0x12345678(%rax,%rcx,8),%bnd0
Decoded ok: f2 0f 1b c0          	bndcn  %rax,%bnd0
Decoded ok: 66 0f 1a 00          	bndmov (%rax),%bnd0
Decoded ok: 66 41 0f 1a 00       	bndmov (%r8),%bnd0
Decoded ok: 66 0f 1a 04 25 78 56 34 12 	bndmov 0x12345678,%bnd0
Decoded ok: 66 0f 1a 18          	bndmov (%rax),%bnd3
Decoded ok: 66 0f 1a 04 01       	bndmov (%rcx,%rax,1),%bnd0
Decoded ok: 66 0f 1a 04 05 78 56 34 12 	bndmov 0x12345678(,%rax,1),%bnd0
Decoded ok: 66 0f 1a 04 08       	bndmov (%rax,%rcx,1),%bnd0
Decoded ok: 66 0f 1a 04 c8       	bndmov (%rax,%rcx,8),%bnd0
Decoded ok: 66 0f 1a 40 12       	bndmov 0x12(%rax),%bnd0
Decoded ok: 66 0f 1a 45 12       	bndmov 0x12(%rbp),%bnd0
Decoded ok: 66 0f 1a 44 01 12    	bndmov 0x12(%rcx,%rax,1),%bnd0
Decoded ok: 66 0f 1a 44 05 12    	bndmov 0x12(%rbp,%rax,1),%bnd0
Decoded ok: 66 0f 1a 44 08 12    	bndmov 0x12(%rax,%rcx,1),%bnd0
Decoded ok: 66 0f 1a 44 c8 12    	bndmov 0x12(%rax,%rcx,8),%bnd0
Decoded ok: 66 0f 1a 80 78 56 34 12 	bndmov 0x12345678(%rax),%bnd0
Decoded ok: 66 0f 1a 85 78 56 34 12 	bndmov 0x12345678(%rbp),%bnd0
Decoded ok: 66 0f 1a 84 01 78 56 34 12 	bndmov 0x12345678(%rcx,%rax,1),%bnd0
Decoded ok: 66 0f 1a 84 05 78 56 34 12 	bndmov 0x12345678(%rbp,%rax,1),%bnd0
Decoded ok: 66 0f 1a 84 08 78 56 34 12 	bndmov 0x12345678(%rax,%rcx,1),%bnd0
Decoded ok: 66 0f 1a 84 c8 78 56 34 12 	bndmov 0x12345678(%rax,%rcx,8),%bnd0
Decoded ok: 66 0f 1b 00          	bndmov %bnd0,(%rax)
Decoded ok: 66 41 0f 1b 00       	bndmov %bnd0,(%r8)
Decoded ok: 66 0f 1b 04 25 78 56 34 12 	bndmov %bnd0,0x12345678
Decoded ok: 66 0f 1b 18          	bndmov %bnd3,(%rax)
Decoded ok: 66 0f 1b 04 01       	bndmov %bnd0,(%rcx,%rax,1)
Decoded ok: 66 0f 1b 04 05 78 56 34 12 	bndmov %bnd0,0x12345678(,%rax,1)
Decoded ok: 66 0f 1b 04 08       	bndmov %bnd0,(%rax,%rcx,1)
Decoded ok: 66 0f 1b 04 c8       	bndmov %bnd0,(%rax,%rcx,8)
Decoded ok: 66 0f 1b 40 12       	bndmov %bnd0,0x12(%rax)
Decoded ok: 66 0f 1b 45 12       	bndmov %bnd0,0x12(%rbp)
Decoded ok: 66 0f 1b 44 01 12    	bndmov %bnd0,0x12(%rcx,%rax,1)
Decoded ok: 66 0f 1b 44 05 12    	bndmov %bnd0,0x12(%rbp,%rax,1)
Decoded ok: 66 0f 1b 44 08 12    	bndmov %bnd0,0x12(%rax,%rcx,1)
Decoded ok: 66 0f 1b 44 c8 12    	bndmov %bnd0,0x12(%rax,%rcx,8)
Decoded ok: 66 0f 1b 80 78 56 34 12 	bndmov %bnd0,0x12345678(%rax)
Decoded ok: 66 0f 1b 85 78 56 34 12 	bndmov %bnd0,0x12345678(%rbp)
Decoded ok: 66 0f 1b 84 01 78 56 34 12 	bndmov %bnd0,0x12345678(%rcx,%rax,1)
Decoded ok: 66 0f 1b 84 05 78 56 34 12 	bndmov %bnd0,0x12345678(%rbp,%rax,1)
Decoded ok: 66 0f 1b 84 08 78 56 34 12 	bndmov %bnd0,0x12345678(%rax,%rcx,1)
Decoded ok: 66 0f 1b 84 c8 78 56 34 12 	bndmov %bnd0,0x12345678(%rax,%rcx,8)
Decoded ok: 66 0f 1a c8          	bndmov %bnd0,%bnd1
Decoded ok: 66 0f 1a c1          	bndmov %bnd1,%bnd0
Decoded ok: 0f 1a 00             	bndldx (%rax),%bnd0
Decoded ok: 41 0f 1a 00          	bndldx (%r8),%bnd0
Decoded ok: 0f 1a 04 25 78 56 34 12 	bndldx 0x12345678,%bnd0
Decoded ok: 0f 1a 18             	bndldx (%rax),%bnd3
Decoded ok: 0f 1a 04 01          	bndldx (%rcx,%rax,1),%bnd0
Decoded ok: 0f 1a 04 05 78 56 34 12 	bndldx 0x12345678(,%rax,1),%bnd0
Decoded ok: 0f 1a 04 08          	bndldx (%rax,%rcx,1),%bnd0
Decoded ok: 0f 1a 40 12          	bndldx 0x12(%rax),%bnd0
Decoded ok: 0f 1a 45 12          	bndldx 0x12(%rbp),%bnd0
Decoded ok: 0f 1a 44 01 12       	bndldx 0x12(%rcx,%rax,1),%bnd0
Decoded ok: 0f 1a 44 05 12       	bndldx 0x12(%rbp,%rax,1),%bnd0
Decoded ok: 0f 1a 44 08 12       	bndldx 0x12(%rax,%rcx,1),%bnd0
Decoded ok: 0f 1a 80 78 56 34 12 	bndldx 0x12345678(%rax),%bnd0
Decoded ok: 0f 1a 85 78 56 34 12 	bndldx 0x12345678(%rbp),%bnd0
Decoded ok: 0f 1a 84 01 78 56 34 12 	bndldx 0x12345678(%rcx,%rax,1),%bnd0
Decoded ok: 0f 1a 84 05 78 56 34 12 	bndldx 0x12345678(%rbp,%rax,1),%bnd0
Decoded ok: 0f 1a 84 08 78 56 34 12 	bndldx 0x12345678(%rax,%rcx,1),%bnd0
Decoded ok: 0f 1b 00             	bndstx %bnd0,(%rax)
Decoded ok: 41 0f 1b 00          	bndstx %bnd0,(%r8)
Decoded ok: 0f 1b 04 25 78 56 34 12 	bndstx %bnd0,0x12345678
Decoded ok: 0f 1b 18             	bndstx %bnd3,(%rax)
Decoded ok: 0f 1b 04 01          	bndstx %bnd0,(%rcx,%rax,1)
Decoded ok: 0f 1b 04 05 78 56 34 12 	bndstx %bnd0,0x12345678(,%rax,1)
Decoded ok: 0f 1b 04 08          	bndstx %bnd0,(%rax,%rcx,1)
Decoded ok: 0f 1b 40 12          	bndstx %bnd0,0x12(%rax)
Decoded ok: 0f 1b 45 12          	bndstx %bnd0,0x12(%rbp)
Decoded ok: 0f 1b 44 01 12       	bndstx %bnd0,0x12(%rcx,%rax,1)
Decoded ok: 0f 1b 44 05 12       	bndstx %bnd0,0x12(%rbp,%rax,1)
Decoded ok: 0f 1b 44 08 12       	bndstx %bnd0,0x12(%rax,%rcx,1)
Decoded ok: 0f 1b 80 78 56 34 12 	bndstx %bnd0,0x12345678(%rax)
Decoded ok: 0f 1b 85 78 56 34 12 	bndstx %bnd0,0x12345678(%rbp)
Decoded ok: 0f 1b 84 01 78 56 34 12 	bndstx %bnd0,0x12345678(%rcx,%rax,1)
Decoded ok: 0f 1b 84 05 78 56 34 12 	bndstx %bnd0,0x12345678(%rbp,%rax,1)
Decoded ok: 0f 1b 84 08 78 56 34 12 	bndstx %bnd0,0x12345678(%rax,%rcx,1)
Decoded ok: f2 e8 00 00 00 00    	bnd callq 3f6 <main+0x3f6>
Decoded ok: 67 f2 ff 10          	bnd callq *(%eax)
Decoded ok: f2 c3                	bnd retq 
Decoded ok: f2 e9 00 00 00 00    	bnd jmpq 402 <main+0x402>
Decoded ok: f2 e9 00 00 00 00    	bnd jmpq 408 <main+0x408>
Decoded ok: 67 f2 ff 21          	bnd jmpq *(%ecx)
Decoded ok: f2 0f 85 00 00 00 00 	bnd jne 413 <main+0x413>
Decoded ok: 0f 3a cc c1 00       	sha1rnds4 $0x0,%xmm1,%xmm0
Decoded ok: 0f 3a cc d7 91       	sha1rnds4 $0x91,%xmm7,%xmm2
Decoded ok: 41 0f 3a cc c0 91    	sha1rnds4 $0x91,%xmm8,%xmm0
Decoded ok: 44 0f 3a cc c7 91    	sha1rnds4 $0x91,%xmm7,%xmm8
Decoded ok: 45 0f 3a cc c7 91    	sha1rnds4 $0x91,%xmm15,%xmm8
Decoded ok: 0f 3a cc 00 91       	sha1rnds4 $0x91,(%rax),%xmm0
Decoded ok: 41 0f 3a cc 00 91    	sha1rnds4 $0x91,(%r8),%xmm0
Decoded ok: 0f 3a cc 04 25 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678,%xmm0
Decoded ok: 0f 3a cc 18 91       	sha1rnds4 $0x91,(%rax),%xmm3
Decoded ok: 0f 3a cc 04 01 91    	sha1rnds4 $0x91,(%rcx,%rax,1),%xmm0
Decoded ok: 0f 3a cc 04 05 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(,%rax,1),%xmm0
Decoded ok: 0f 3a cc 04 08 91    	sha1rnds4 $0x91,(%rax,%rcx,1),%xmm0
Decoded ok: 0f 3a cc 04 c8 91    	sha1rnds4 $0x91,(%rax,%rcx,8),%xmm0
Decoded ok: 0f 3a cc 40 12 91    	sha1rnds4 $0x91,0x12(%rax),%xmm0
Decoded ok: 0f 3a cc 45 12 91    	sha1rnds4 $0x91,0x12(%rbp),%xmm0
Decoded ok: 0f 3a cc 44 01 12 91 	sha1rnds4 $0x91,0x12(%rcx,%rax,1),%xmm0
Decoded ok: 0f 3a cc 44 05 12 91 	sha1rnds4 $0x91,0x12(%rbp,%rax,1),%xmm0
Decoded ok: 0f 3a cc 44 08 12 91 	sha1rnds4 $0x91,0x12(%rax,%rcx,1),%xmm0
Decoded ok: 0f 3a cc 44 c8 12 91 	sha1rnds4 $0x91,0x12(%rax,%rcx,8),%xmm0
Decoded ok: 0f 3a cc 80 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rax),%xmm0
Decoded ok: 0f 3a cc 85 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rbp),%xmm0
Decoded ok: 0f 3a cc 84 01 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rcx,%rax,1),%xmm0
Decoded ok: 0f 3a cc 84 05 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rbp,%rax,1),%xmm0
Decoded ok: 0f 3a cc 84 08 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rax,%rcx,1),%xmm0
Decoded ok: 0f 3a cc 84 c8 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rax,%rcx,8),%xmm0
Decoded ok: 44 0f 3a cc bc c8 78 56 34 12 91 	sha1rnds4 $0x91,0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 0f 38 c8 c1          	sha1nexte %xmm1,%xmm0
Decoded ok: 0f 38 c8 d7          	sha1nexte %xmm7,%xmm2
Decoded ok: 41 0f 38 c8 c0       	sha1nexte %xmm8,%xmm0
Decoded ok: 44 0f 38 c8 c7       	sha1nexte %xmm7,%xmm8
Decoded ok: 45 0f 38 c8 c7       	sha1nexte %xmm15,%xmm8
Decoded ok: 0f 38 c8 00          	sha1nexte (%rax),%xmm0
Decoded ok: 41 0f 38 c8 00       	sha1nexte (%r8),%xmm0
Decoded ok: 0f 38 c8 04 25 78 56 34 12 	sha1nexte 0x12345678,%xmm0
Decoded ok: 0f 38 c8 18          	sha1nexte (%rax),%xmm3
Decoded ok: 0f 38 c8 04 01       	sha1nexte (%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 c8 04 05 78 56 34 12 	sha1nexte 0x12345678(,%rax,1),%xmm0
Decoded ok: 0f 38 c8 04 08       	sha1nexte (%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 c8 04 c8       	sha1nexte (%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 c8 40 12       	sha1nexte 0x12(%rax),%xmm0
Decoded ok: 0f 38 c8 45 12       	sha1nexte 0x12(%rbp),%xmm0
Decoded ok: 0f 38 c8 44 01 12    	sha1nexte 0x12(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 c8 44 05 12    	sha1nexte 0x12(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 c8 44 08 12    	sha1nexte 0x12(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 c8 44 c8 12    	sha1nexte 0x12(%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 c8 80 78 56 34 12 	sha1nexte 0x12345678(%rax),%xmm0
Decoded ok: 0f 38 c8 85 78 56 34 12 	sha1nexte 0x12345678(%rbp),%xmm0
Decoded ok: 0f 38 c8 84 01 78 56 34 12 	sha1nexte 0x12345678(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 c8 84 05 78 56 34 12 	sha1nexte 0x12345678(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 c8 84 08 78 56 34 12 	sha1nexte 0x12345678(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 c8 84 c8 78 56 34 12 	sha1nexte 0x12345678(%rax,%rcx,8),%xmm0
Decoded ok: 44 0f 38 c8 bc c8 78 56 34 12 	sha1nexte 0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 0f 38 c9 c1          	sha1msg1 %xmm1,%xmm0
Decoded ok: 0f 38 c9 d7          	sha1msg1 %xmm7,%xmm2
Decoded ok: 41 0f 38 c9 c0       	sha1msg1 %xmm8,%xmm0
Decoded ok: 44 0f 38 c9 c7       	sha1msg1 %xmm7,%xmm8
Decoded ok: 45 0f 38 c9 c7       	sha1msg1 %xmm15,%xmm8
Decoded ok: 0f 38 c9 00          	sha1msg1 (%rax),%xmm0
Decoded ok: 41 0f 38 c9 00       	sha1msg1 (%r8),%xmm0
Decoded ok: 0f 38 c9 04 25 78 56 34 12 	sha1msg1 0x12345678,%xmm0
Decoded ok: 0f 38 c9 18          	sha1msg1 (%rax),%xmm3
Decoded ok: 0f 38 c9 04 01       	sha1msg1 (%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 c9 04 05 78 56 34 12 	sha1msg1 0x12345678(,%rax,1),%xmm0
Decoded ok: 0f 38 c9 04 08       	sha1msg1 (%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 c9 04 c8       	sha1msg1 (%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 c9 40 12       	sha1msg1 0x12(%rax),%xmm0
Decoded ok: 0f 38 c9 45 12       	sha1msg1 0x12(%rbp),%xmm0
Decoded ok: 0f 38 c9 44 01 12    	sha1msg1 0x12(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 c9 44 05 12    	sha1msg1 0x12(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 c9 44 08 12    	sha1msg1 0x12(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 c9 44 c8 12    	sha1msg1 0x12(%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 c9 80 78 56 34 12 	sha1msg1 0x12345678(%rax),%xmm0
Decoded ok: 0f 38 c9 85 78 56 34 12 	sha1msg1 0x12345678(%rbp),%xmm0
Decoded ok: 0f 38 c9 84 01 78 56 34 12 	sha1msg1 0x12345678(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 c9 84 05 78 56 34 12 	sha1msg1 0x12345678(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 c9 84 08 78 56 34 12 	sha1msg1 0x12345678(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 c9 84 c8 78 56 34 12 	sha1msg1 0x12345678(%rax,%rcx,8),%xmm0
Decoded ok: 44 0f 38 c9 bc c8 78 56 34 12 	sha1msg1 0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 0f 38 ca c1          	sha1msg2 %xmm1,%xmm0
Decoded ok: 0f 38 ca d7          	sha1msg2 %xmm7,%xmm2
Decoded ok: 41 0f 38 ca c0       	sha1msg2 %xmm8,%xmm0
Decoded ok: 44 0f 38 ca c7       	sha1msg2 %xmm7,%xmm8
Decoded ok: 45 0f 38 ca c7       	sha1msg2 %xmm15,%xmm8
Decoded ok: 0f 38 ca 00          	sha1msg2 (%rax),%xmm0
Decoded ok: 41 0f 38 ca 00       	sha1msg2 (%r8),%xmm0
Decoded ok: 0f 38 ca 04 25 78 56 34 12 	sha1msg2 0x12345678,%xmm0
Decoded ok: 0f 38 ca 18          	sha1msg2 (%rax),%xmm3
Decoded ok: 0f 38 ca 04 01       	sha1msg2 (%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 ca 04 05 78 56 34 12 	sha1msg2 0x12345678(,%rax,1),%xmm0
Decoded ok: 0f 38 ca 04 08       	sha1msg2 (%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 ca 04 c8       	sha1msg2 (%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 ca 40 12       	sha1msg2 0x12(%rax),%xmm0
Decoded ok: 0f 38 ca 45 12       	sha1msg2 0x12(%rbp),%xmm0
Decoded ok: 0f 38 ca 44 01 12    	sha1msg2 0x12(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 ca 44 05 12    	sha1msg2 0x12(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 ca 44 08 12    	sha1msg2 0x12(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 ca 44 c8 12    	sha1msg2 0x12(%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 ca 80 78 56 34 12 	sha1msg2 0x12345678(%rax),%xmm0
Decoded ok: 0f 38 ca 85 78 56 34 12 	sha1msg2 0x12345678(%rbp),%xmm0
Decoded ok: 0f 38 ca 84 01 78 56 34 12 	sha1msg2 0x12345678(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 ca 84 05 78 56 34 12 	sha1msg2 0x12345678(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 ca 84 08 78 56 34 12 	sha1msg2 0x12345678(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 ca 84 c8 78 56 34 12 	sha1msg2 0x12345678(%rax,%rcx,8),%xmm0
Decoded ok: 44 0f 38 ca bc c8 78 56 34 12 	sha1msg2 0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 0f 38 cb cc          	sha256rnds2 %xmm0,%xmm4,%xmm1
Decoded ok: 0f 38 cb d7          	sha256rnds2 %xmm0,%xmm7,%xmm2
Decoded ok: 41 0f 38 cb c8       	sha256rnds2 %xmm0,%xmm8,%xmm1
Decoded ok: 44 0f 38 cb c7       	sha256rnds2 %xmm0,%xmm7,%xmm8
Decoded ok: 45 0f 38 cb c7       	sha256rnds2 %xmm0,%xmm15,%xmm8
Decoded ok: 0f 38 cb 08          	sha256rnds2 %xmm0,(%rax),%xmm1
Decoded ok: 41 0f 38 cb 08       	sha256rnds2 %xmm0,(%r8),%xmm1
Decoded ok: 0f 38 cb 0c 25 78 56 34 12 	sha256rnds2 %xmm0,0x12345678,%xmm1
Decoded ok: 0f 38 cb 18          	sha256rnds2 %xmm0,(%rax),%xmm3
Decoded ok: 0f 38 cb 0c 01       	sha256rnds2 %xmm0,(%rcx,%rax,1),%xmm1
Decoded ok: 0f 38 cb 0c 05 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(,%rax,1),%xmm1
Decoded ok: 0f 38 cb 0c 08       	sha256rnds2 %xmm0,(%rax,%rcx,1),%xmm1
Decoded ok: 0f 38 cb 0c c8       	sha256rnds2 %xmm0,(%rax,%rcx,8),%xmm1
Decoded ok: 0f 38 cb 48 12       	sha256rnds2 %xmm0,0x12(%rax),%xmm1
Decoded ok: 0f 38 cb 4d 12       	sha256rnds2 %xmm0,0x12(%rbp),%xmm1
Decoded ok: 0f 38 cb 4c 01 12    	sha256rnds2 %xmm0,0x12(%rcx,%rax,1),%xmm1
Decoded ok: 0f 38 cb 4c 05 12    	sha256rnds2 %xmm0,0x12(%rbp,%rax,1),%xmm1
Decoded ok: 0f 38 cb 4c 08 12    	sha256rnds2 %xmm0,0x12(%rax,%rcx,1),%xmm1
Decoded ok: 0f 38 cb 4c c8 12    	sha256rnds2 %xmm0,0x12(%rax,%rcx,8),%xmm1
Decoded ok: 0f 38 cb 88 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rax),%xmm1
Decoded ok: 0f 38 cb 8d 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rbp),%xmm1
Decoded ok: 0f 38 cb 8c 01 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rcx,%rax,1),%xmm1
Decoded ok: 0f 38 cb 8c 05 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rbp,%rax,1),%xmm1
Decoded ok: 0f 38 cb 8c 08 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rax,%rcx,1),%xmm1
Decoded ok: 0f 38 cb 8c c8 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rax,%rcx,8),%xmm1
Decoded ok: 44 0f 38 cb bc c8 78 56 34 12 	sha256rnds2 %xmm0,0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 0f 38 cc c1          	sha256msg1 %xmm1,%xmm0
Decoded ok: 0f 38 cc d7          	sha256msg1 %xmm7,%xmm2
Decoded ok: 41 0f 38 cc c0       	sha256msg1 %xmm8,%xmm0
Decoded ok: 44 0f 38 cc c7       	sha256msg1 %xmm7,%xmm8
Decoded ok: 45 0f 38 cc c7       	sha256msg1 %xmm15,%xmm8
Decoded ok: 0f 38 cc 00          	sha256msg1 (%rax),%xmm0
Decoded ok: 41 0f 38 cc 00       	sha256msg1 (%r8),%xmm0
Decoded ok: 0f 38 cc 04 25 78 56 34 12 	sha256msg1 0x12345678,%xmm0
Decoded ok: 0f 38 cc 18          	sha256msg1 (%rax),%xmm3
Decoded ok: 0f 38 cc 04 01       	sha256msg1 (%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 cc 04 05 78 56 34 12 	sha256msg1 0x12345678(,%rax,1),%xmm0
Decoded ok: 0f 38 cc 04 08       	sha256msg1 (%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 cc 04 c8       	sha256msg1 (%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 cc 40 12       	sha256msg1 0x12(%rax),%xmm0
Decoded ok: 0f 38 cc 45 12       	sha256msg1 0x12(%rbp),%xmm0
Decoded ok: 0f 38 cc 44 01 12    	sha256msg1 0x12(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 cc 44 05 12    	sha256msg1 0x12(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 cc 44 08 12    	sha256msg1 0x12(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 cc 44 c8 12    	sha256msg1 0x12(%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 cc 80 78 56 34 12 	sha256msg1 0x12345678(%rax),%xmm0
Decoded ok: 0f 38 cc 85 78 56 34 12 	sha256msg1 0x12345678(%rbp),%xmm0
Decoded ok: 0f 38 cc 84 01 78 56 34 12 	sha256msg1 0x12345678(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 cc 84 05 78 56 34 12 	sha256msg1 0x12345678(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 cc 84 08 78 56 34 12 	sha256msg1 0x12345678(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 cc 84 c8 78 56 34 12 	sha256msg1 0x12345678(%rax,%rcx,8),%xmm0
Decoded ok: 44 0f 38 cc bc c8 78 56 34 12 	sha256msg1 0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 0f 38 cd c1          	sha256msg2 %xmm1,%xmm0
Decoded ok: 0f 38 cd d7          	sha256msg2 %xmm7,%xmm2
Decoded ok: 41 0f 38 cd c0       	sha256msg2 %xmm8,%xmm0
Decoded ok: 44 0f 38 cd c7       	sha256msg2 %xmm7,%xmm8
Decoded ok: 45 0f 38 cd c7       	sha256msg2 %xmm15,%xmm8
Decoded ok: 0f 38 cd 00          	sha256msg2 (%rax),%xmm0
Decoded ok: 41 0f 38 cd 00       	sha256msg2 (%r8),%xmm0
Decoded ok: 0f 38 cd 04 25 78 56 34 12 	sha256msg2 0x12345678,%xmm0
Decoded ok: 0f 38 cd 18          	sha256msg2 (%rax),%xmm3
Decoded ok: 0f 38 cd 04 01       	sha256msg2 (%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 cd 04 05 78 56 34 12 	sha256msg2 0x12345678(,%rax,1),%xmm0
Decoded ok: 0f 38 cd 04 08       	sha256msg2 (%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 cd 04 c8       	sha256msg2 (%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 cd 40 12       	sha256msg2 0x12(%rax),%xmm0
Decoded ok: 0f 38 cd 45 12       	sha256msg2 0x12(%rbp),%xmm0
Decoded ok: 0f 38 cd 44 01 12    	sha256msg2 0x12(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 cd 44 05 12    	sha256msg2 0x12(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 cd 44 08 12    	sha256msg2 0x12(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 cd 44 c8 12    	sha256msg2 0x12(%rax,%rcx,8),%xmm0
Decoded ok: 0f 38 cd 80 78 56 34 12 	sha256msg2 0x12345678(%rax),%xmm0
Decoded ok: 0f 38 cd 85 78 56 34 12 	sha256msg2 0x12345678(%rbp),%xmm0
Decoded ok: 0f 38 cd 84 01 78 56 34 12 	sha256msg2 0x12345678(%rcx,%rax,1),%xmm0
Decoded ok: 0f 38 cd 84 05 78 56 34 12 	sha256msg2 0x12345678(%rbp,%rax,1),%xmm0
Decoded ok: 0f 38 cd 84 08 78 56 34 12 	sha256msg2 0x12345678(%rax,%rcx,1),%xmm0
Decoded ok: 0f 38 cd 84 c8 78 56 34 12 	sha256msg2 0x12345678(%rax,%rcx,8),%xmm0
Decoded ok: 44 0f 38 cd bc c8 78 56 34 12 	sha256msg2 0x12345678(%rax,%rcx,8),%xmm15
Decoded ok: 66 0f ae 38          	clflushopt (%rax)
Decoded ok: 66 41 0f ae 38       	clflushopt (%r8)
Decoded ok: 66 0f ae 3c 25 78 56 34 12 	clflushopt 0x12345678
Decoded ok: 66 0f ae bc c8 78 56 34 12 	clflushopt 0x12345678(%rax,%rcx,8)
Decoded ok: 66 41 0f ae bc c8 78 56 34 12 	clflushopt 0x12345678(%r8,%rcx,8)
Decoded ok: 0f ae 38             	clflush (%rax)
Decoded ok: 41 0f ae 38          	clflush (%r8)
Decoded ok: 0f ae f8             	sfence 
Decoded ok: 66 0f ae 30          	clwb   (%rax)
Decoded ok: 66 41 0f ae 30       	clwb   (%r8)
Decoded ok: 66 0f ae 34 25 78 56 34 12 	clwb   0x12345678
Decoded ok: 66 0f ae b4 c8 78 56 34 12 	clwb   0x12345678(%rax,%rcx,8)
Decoded ok: 66 41 0f ae b4 c8 78 56 34 12 	clwb   0x12345678(%r8,%rcx,8)
Decoded ok: 0f ae 30             	xsaveopt (%rax)
Decoded ok: 41 0f ae 30          	xsaveopt (%r8)
Decoded ok: 0f ae f0             	mfence 
Decoded ok: 0f c7 20             	xsavec (%rax)
Decoded ok: 41 0f c7 20          	xsavec (%r8)
Decoded ok: 0f c7 24 25 78 56 34 12 	xsavec 0x12345678
Decoded ok: 0f c7 a4 c8 78 56 34 12 	xsavec 0x12345678(%rax,%rcx,8)
Decoded ok: 41 0f c7 a4 c8 78 56 34 12 	xsavec 0x12345678(%r8,%rcx,8)
Decoded ok: 0f c7 28             	xsaves (%rax)
Decoded ok: 41 0f c7 28          	xsaves (%r8)
Decoded ok: 0f c7 2c 25 78 56 34 12 	xsaves 0x12345678
Decoded ok: 0f c7 ac c8 78 56 34 12 	xsaves 0x12345678(%rax,%rcx,8)
Decoded ok: 41 0f c7 ac c8 78 56 34 12 	xsaves 0x12345678(%r8,%rcx,8)
Decoded ok: 0f c7 18             	xrstors (%rax)
Decoded ok: 41 0f c7 18          	xrstors (%r8)
Decoded ok: 0f c7 1c 25 78 56 34 12 	xrstors 0x12345678
Decoded ok: 0f c7 9c c8 78 56 34 12 	xrstors 0x12345678(%rax,%rcx,8)
Decoded ok: 41 0f c7 9c c8 78 56 34 12 	xrstors 0x12345678(%r8,%rcx,8)
Decoded ok: 66 0f ae f8          	pcommit 
Decoded ok: 0f 01 ee             	rdpkru
Decoded ok: 0f 01 ef             	wrpkru
test child finished with 0
---- end ----
Test x86 instruction decoder - new instructions: Ok
48: Test intel cqm nmi context read                          :
--- start ---
test child forked, pid 22924
parse_events failed, is "intel_cqm/llc_occupancy/" available?
test child finished with -2
---- end ----
Test intel cqm nmi context read: Skip
[acme@zoo linux]$ 
