From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN command
Date: Fri, 31 Mar 2017 10:53:50 +0800
Message-ID: <9105ab34-8fee-fab4-96fe-3bfe7f3a84b7@huawei.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:4928 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750820AbdCaCyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 22:54:45 -0400
In-Reply-To: <20170331013157.3298003-2-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/3/31 9:31, Alexei Starovoitov wrote:
> development and testing of networking bpf programs is quite cumbersome.
> Despite availability of user space bpf interpreters the kernel is
> the ultimate authority and execution environment.
> Current test frameworks for TC include creation of netns, veth,
> qdiscs and use of various packet generators just to test functionality
> of a bpf program. XDP testing is even more complicated, since
> qemu needs to be started with gro/gso disabled and precise queue
> configuration, transferring of xdp program from host into guest,
> attaching to virtio/eth0 and generating traffic from the host
> while capturing the results from the guest.
>
> Moreover analyzing performance bottlenecks in XDP program is
> impossible in virtio environment, since cost of running the program
> is tiny comparing to the overhead of virtio packet processing,
> so performance testing can only be done on physical nic
> with another server generating traffic.
>
> Furthermore ongoing changes to user space control plane of production
> applications cannot be run on the test servers leaving bpf programs
> stubbed out for testing.
>
> Last but not least, the upstream llvm changes are validated by the bpf
> backend testsuite which has no ability to test the code generated.
>
> To improve this situation introduce BPF_PROG_TEST_RUN command
> to test and performance benchmark bpf programs.
>
> Joint work with Daniel Borkmann.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   include/linux/bpf.h      |   7 ++
>   include/uapi/linux/bpf.h |  12 ++++
>   kernel/bpf/syscall.c     |  27 +++++++-
>   net/Makefile             |   2 +-
>   net/bpf/Makefile         |   1 +
>   net/bpf/test_run.c       | 172 +++++++++++++++++++++++++++++++++++++++++++++++
>   net/core/filter.c        |   5 ++
>   7 files changed, 223 insertions(+), 3 deletions(-)
>   create mode 100644 net/bpf/Makefile
>   create mode 100644 net/bpf/test_run.c
>

[SNIP]

> diff --git a/net/Makefile b/net/Makefile
> index 9b681550e3a3..9086ffbb5085 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -12,7 +12,7 @@ obj-$(CONFIG_NET)		+= $(tmp-y)
>   
>   # LLC has to be linked before the files in net/802/
>   obj-$(CONFIG_LLC)		+= llc/
> -obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/
> +obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/ bpf/
>   obj-$(CONFIG_NETFILTER)		+= netfilter/
>   obj-$(CONFIG_INET)		+= ipv4/
>   obj-$(CONFIG_XFRM)		+= xfrm/
> diff --git a/net/bpf/Makefile b/net/bpf/Makefile
> new file mode 100644
> index 000000000000..27b2992a0692
> --- /dev/null
> +++ b/net/bpf/Makefile
> @@ -0,0 +1 @@
> +obj-y	:= test_run.o

I suggest using a CONFIG option to enable/disable code in
test_run.o to reduce attack plane.

Thank you.
