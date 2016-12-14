From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCHv3 perf/core 0/7] Reuse libbpf from samples/bpf
Date: Wed, 14 Dec 2016 14:46:23 -0800
Message-ID: <CAPWQB7E-i+m0Ukz6O39AV-pHMB=GsoUTTa1862QUjGWM3RQJyQ@mail.gmail.com>
References: <20161209024620.31660-1-joe@ovn.org> <20161209150907.GM8257@kernel.org>
 <584ACE2E.2090108@iogearbox.net> <20161214132501.GP5482@kernel.org> <20161214145512.GQ5482@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Wang Nan <wangnan0@huawei.com>,
        ast@fb.com
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161214145512.GQ5482@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 December 2016 at 06:55, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> Em Wed, Dec 14, 2016 at 10:25:01AM -0300, Arnaldo Carvalho de Melo escreveu:
>> Em Fri, Dec 09, 2016 at 04:30:54PM +0100, Daniel Borkmann escreveu:
>> > On 12/09/2016 04:09 PM, Arnaldo Carvalho de Melo wrote:
>> > Please note that this might result in hopefully just a minor merge issue
>> > with net-next. Looks like patch 4/7 touches test_maps.c and test_verifier.c,
>> > which moved to a new bpf selftest suite [1] this net-next cycle. Seems it's
>> > just log buffer and some renames there, which can be discarded for both
>> > files sitting in selftests.
>>
>> Yeah, I've got to this point, and the merge has a little bit more than
>> that, including BPF_PROG_ATTACH/BPF_PROG_DETACH, etc, working on it...
>
> So, Joe, can you try refreshing this work, starting from what I have in
> perf/core? It has the changes coming from net-next that Daniel warned us about
> and some more.

Hi Arnaldo,

I've just respun this series based on the version you previously
applied to perf/core. Since bpf_prog_{attach,detach}() were added to
samples/libbpf, a new patch will shift these over to tools/lib/bpf.
Other than that, I folded "samples/bpf: Drop unnecessary build
targets." back into "samples/bpf: Switch over to libbpf", and I
noticed that there were a couple of unnecessary log buffers with the
latest changes. For any new sample programs, those were fixed up to
use libbpf as well.

Don't forget to do a "make headers_install" before attempting to build
the samples, access to the latest headers is required (as per the
readme in samples/bpf).

Thanks,
Joe
