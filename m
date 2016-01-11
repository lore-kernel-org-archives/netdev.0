From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 14/53] perf test: Check environment before start real BPF
 test
Date: Mon, 11 Jan 2016 18:55:03 -0300
Message-ID: <20160111215503.GJ18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-15-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452520124-2073-15-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 01:48:05PM +0000, Wang Nan escreveu:
> Copying perf to old kernel system results:
> 
>  # perf test bpf
>  37: Test BPF filter                                          :
>  37.1: Test basic BPF filtering                               : FAILED!
>  37.2: Test BPF prologue generation                           : Skip
> 
> However, in case when kernel doesn't support a test case it should
> return 'Skip', 'FAILED!' should be reserved for kernel tests for when
> the kernel supports a feature that then fails to work as advertised.
> 
> This patch checks environment before real testcase.

This is really strange, this other test is failing if the above patch is
present, found by bisecting:

[acme@felicio linux]$ perf test decoder
47: Test x86 instruction decoder - new instructions          : FAILED!
[acme@felicio linux]$ git log --oneline -1
91fedd318e3d perf test: Check environment before start real BPF test
[acme@felicio linux]$ git reset --hard HEAD^
HEAD is now at f1f23526d3b6 perf test: Reset err after using it hold
errcode in hist testcases
[acme@felicio linux]$ m
make: Entering directory `/home/acme/git/linux/tools/perf'
  BUILD:   Doing 'make -j4' parallel build
  CC       /tmp/build/perf/arch/common.o
  CC       /tmp/build/perf/util/abspath.o
  CC       /tmp/build/perf/builtin-bench.o
  CC       /tmp/build/perf/util/alias.o

<SNIP>
[acme@felicio linux]$ git log --oneline -1
f1f23526d3b6 perf test: Reset err after using it hold errcode in hist
testcases
[acme@felicio linux]$ perf test decoder
47: Test x86 instruction decoder - new instructions          : Ok
[acme@felicio linux]$ 
