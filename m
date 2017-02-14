From: Joe Stringer <joe@ovn.org>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 13 Feb 2017 23:59:42 -0800
Message-ID: <CAPWQB7GPyiN+5rdLRyXA4v03-2hPZ=Xfw_URFyuFjTQo+=C1Dg@mail.gmail.com>
References: <20170214091250.57d054b2@canb.auug.org.au> <58A241EC.8050400@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Wang Nan <wangnan0@huawei.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <58A241EC.8050400@fb.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13 February 2017 at 15:31, Alexei Starovoitov <ast@fb.com> wrote:
> On 2/13/17 2:12 PM, Stephen Rothwell wrote:
>>
>> Hi all,
>>
>> After merging the net tree, today's linux-next build (powerpc64le perf)
>> failed like this:
>>
>> Warning: tools/include/uapi/linux/bpf.h differs from kernel
>> bpf.c: In function 'bpf_prog_attach':
>> bpf.c:180:6: error: 'union bpf_attr' has no member named 'attach_flags';
>> did you mean 'map_flags'?
>>    attr.attach_flags  = flags;
>>        ^
>>
>> Caused by commit
>>
>>    7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE flag")
>>
>> Unfortunately, the perf header files are kept separate from the kernel
>> header files proper and are not automatically copied over :-(
>>
>> I have applied the following build fix patch for today.
>
>
> Yes. Thanks for the fix. It's more than a merge conflict.
> I should have added it in the first place. Now we have both
> perf and samples/bpf depend on tools/lib/bpf and I simply
> forgot about this dependency, since building perf
> is not my typical workflow.
>
> Joe,
> can you think of a way to make tools/lib/bpf to
> use tools/include only?
> Right now we just pull tools/lib/bpf/bpf.o in samples/bpf/Makefile
> and that's a hack that caused this issue.
> samples/bpf/ needs to depend on libbpf.a properly.

Honestly the build system stuff is all black magic to me.

Originally I had a line in the samples/bpf makefile that changed
directory and ran make there, but it was limited in that it only
addressed the 'all' target so you could still hit issues when trying
to build specific samples directly via their own targets so I removed
it on request:

https://patchwork.kernel.org/patch/9472573/
