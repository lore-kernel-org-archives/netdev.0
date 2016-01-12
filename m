From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 14/53] perf test: Check environment before start real
 BPF test
Date: Tue, 12 Jan 2016 15:40:40 +0800
Message-ID: <5694ADF8.3080403@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com> <1452520124-2073-15-git-send-email-wangnan0@huawei.com> <20160111215503.GJ18367@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111215503.GJ18367@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/12 5:55, Arnaldo Carvalho de Melo wrote:
> Em Mon, Jan 11, 2016 at 01:48:05PM +0000, Wang Nan escreveu:
>> Copying perf to old kernel system results:
>>
>>   # perf test bpf
>>   37: Test BPF filter                                          :
>>   37.1: Test basic BPF filtering                               : FAILED!
>>   37.2: Test BPF prologue generation                           : Skip
>>
>> However, in case when kernel doesn't support a test case it should
>> return 'Skip', 'FAILED!' should be reserved for kernel tests for when
>> the kernel supports a feature that then fails to work as advertised.
>>
>> This patch checks environment before real testcase.
> This is really strange, this other test is failing if the above patch is
> present, found by bisecting:
>
> [acme@felicio linux]$ perf test decoder
> 47: Test x86 instruction decoder - new instructions          : FAILED!
> [acme@felicio linux]$ git log --oneline -1
> 91fedd318e3d perf test: Check environment before start real BPF test
> [acme@felicio linux]$ git reset --hard HEAD^
> HEAD is now at f1f23526d3b6 perf test: Reset err after using it hold
> errcode in hist testcases
> [acme@felicio linux]$ m
> make: Entering directory `/home/acme/git/linux/tools/perf'
>    BUILD:   Doing 'make -j4' parallel build
>    CC       /tmp/build/perf/arch/common.o
>    CC       /tmp/build/perf/util/abspath.o
>    CC       /tmp/build/perf/builtin-bench.o
>    CC       /tmp/build/perf/util/alias.o
>
> <SNIP>
> [acme@felicio linux]$ git log --oneline -1
> f1f23526d3b6 perf test: Reset err after using it hold errcode in hist
> testcases
> [acme@felicio linux]$ perf test decoder
> 47: Test x86 instruction decoder - new instructions          : Ok
> [acme@felicio linux]$

Yes, really strange, and I can't reproduce your result
in my environment. What's the result of test -v?

Thank you.
