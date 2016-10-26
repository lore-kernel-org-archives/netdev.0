From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix samples to add fake KBUILD_MODNAME
Date: Wed, 26 Oct 2016 09:01:48 +0200
Message-ID: <581054DC.5000904@iogearbox.net>
References: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net> <20161026011713.GA35732@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080103040102020907010405"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48107 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753396AbcJZHBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 03:01:55 -0400
In-Reply-To: <20161026011713.GA35732@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080103040102020907010405
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 10/26/2016 03:17 AM, Alexei Starovoitov wrote:
> On Wed, Oct 26, 2016 at 12:37:53AM +0200, Daniel Borkmann wrote:
>> Some of the sample files are causing issues when they are loaded with tc
>> and cls_bpf, meaning tc bails out while trying to parse the resulting ELF
>> file as program/map/etc sections are not present, which can be easily
>> spotted with readelf(1).
>>
>> Currently, BPF samples are including some of the kernel headers and mid
>> term we should change them to refrain from this, really. When dynamic
>> debugging is enabled, we bail out due to undeclared KBUILD_MODNAME, which
>> is easily overlooked in the build as clang spills this along with other
>> noisy warnings from various header includes, and llc still generates an
>> ELF file with mentioned characteristics. For just playing around with BPF
>> examples, this can be a bit of a hurdle to take.
>>
>> Just add a fake KBUILD_MODNAME as a band-aid to fix the issue, same is
>> done in xdp*_kern samples already.
>>
>> Fixes: 65d472fb007d ("samples/bpf: add 'pointer to packet' tests")
>> Fixes: 6afb1e28b859 ("samples/bpf: Add tunnel set/get tests.")
>> Fixes: a3f74617340b ("cgroup: bpf: Add an example to do cgroup checking in BPF")
>> Reported-by: Chandrasekar Kannan <ckannan@console.to>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>   samples/bpf/parse_ldabs.c        | 1 +
>>   samples/bpf/parse_simple.c       | 1 +
>>   samples/bpf/parse_varlen.c       | 1 +
>>   samples/bpf/tcbpf1_kern.c        | 1 +
>>   samples/bpf/tcbpf2_kern.c        | 1 +
>>   samples/bpf/test_cgrp2_tc_kern.c | 1 +
>>   6 files changed, 6 insertions(+)
>
> It's also needed for all of tracex*_kern.c, right?

Rest compiles just fine for me and readelf output looks good on all
tracex*_kern.o, too.

I see just warnings coming from various kernel header inclusions (see
log), but no errors anymore.

--------------080103040102020907010405
Content-Type: text/plain; charset=UTF-8;
 name="log"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="log"

/home/darkstar/net/samples/bpf/trace_output_user.c:64:6: warning: no previous prototype for ‘perf_event_read’ [-Wmissing-prototypes]
 void perf_event_read(print_fn fn)
      ^
In file included from /home/darkstar/net/samples/bpf/sockex2_kern.c:8:
In file included from ./include/uapi/linux/if_tunnel.h:6:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/sockex2_kern.c:8:
In file included from ./include/uapi/linux/if_tunnel.h:6:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/sockex3_kern.c:14:
In file included from ./include/uapi/linux/if_tunnel.h:6:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/sockex3_kern.c:14:
In file included from ./include/uapi/linux/if_tunnel.h:6:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/tracex1_kern.c:7:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/tracex1_kern.c:7:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/tracex2_kern.c:7:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/tracex2_kern.c:7:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/tracex3_kern.c:7:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/tracex3_kern.c:7:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/tracex4_kern.c:7:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/tracex5_kern.c:7:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/tracex6_kern.c:1:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/test_probe_write_user_kern.c:7:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/test_probe_write_user_kern.c:7:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/trace_output_kern.c:1:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/tcbpf2_kern.c:18:
In file included from ./include/net/ipv6.h:16:
In file included from ./include/linux/ipv6.h:76:
In file included from ./include/linux/icmpv6.h:4:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/tcbpf2_kern.c:18:
In file included from ./include/net/ipv6.h:16:
In file included from ./include/linux/ipv6.h:76:
In file included from ./include/linux/icmpv6.h:4:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/lathist_kern.c:9:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/offwaketime_kern.c:12:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/spintest_kern.c:7:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/spintest_kern.c:7:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/map_perf_test_kern.c:7:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/map_perf_test_kern.c:7:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/test_overhead_kprobe_kern.c:8:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/parse_varlen.c:8:
In file included from ./include/linux/if_ether.h:23:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/parse_varlen.c:8:
In file included from ./include/linux/if_ether.h:23:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/parse_simple.c:8:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/parse_simple.c:8:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/parse_ldabs.c:8:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/parse_ldabs.c:8:
In file included from ./include/linux/ip.h:20:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/xdp1_kern.c:10:
In file included from ./include/linux/if_ether.h:23:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/xdp1_kern.c:10:
In file included from ./include/linux/if_ether.h:23:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/xdp2_kern.c:10:
In file included from ./include/linux/if_ether.h:23:
In file included from ./include/linux/skbuff.h:29:
In file included from ./include/linux/net.h:28:
./include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false [-Wtautological-compare]
        if (id < 0 || id >= READING_MAX_ID)
            ~~ ^ ~
In file included from /home/darkstar/net/samples/bpf/xdp2_kern.c:10:
In file included from ./include/linux/if_ether.h:23:
In file included from ./include/linux/skbuff.h:30:
In file included from ./include/linux/textsearch.h:8:
In file included from ./include/linux/slab.h:118:
In file included from ./include/linux/kasan.h:4:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
2 warnings generated.
In file included from /home/darkstar/net/samples/bpf/test_current_task_under_cgroup_kern.c:8:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/trace_event_kern.c:7:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.
In file included from /home/darkstar/net/samples/bpf/sampleip_kern.c:8:
In file included from ./include/linux/ptrace.h:5:
In file included from ./include/linux/sched.h:61:
./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
        struct cgroup cgrp;
                      ^
1 warning generated.

--------------080103040102020907010405--
