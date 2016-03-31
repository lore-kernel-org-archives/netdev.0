From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 3/4] samples/bpf: Simplify building BPF samples
Date: Thu, 31 Mar 2016 10:49:31 -0700
Message-ID: <56FD632B.4040306@fb.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <0ce1c8bdff478db55490a90db6732c4db9de6f22.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0ce1c8bdff478db55490a90db6732c4db9de6f22.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> Make BPF samples build depend on CONFIG_SAMPLE_BPF. We still don't add a
> Kconfig option since that will add a dependency on llvm for allyesconfig
> builds which may not be desirable.
>
> Those who need to build the BPF samples can now just do:
>
> make CONFIG_SAMPLE_BPF=y
>
> or:
>
> export CONFIG_SAMPLE_BPF=y
> make

I don't like this 'simplification'.
make samples/bpf/
is much easier to type than capital letters.

> diff --git a/samples/Makefile b/samples/Makefile
> index 48001d7..3c77fc8 100644
> --- a/samples/Makefile
> +++ b/samples/Makefile
> @@ -2,4 +2,4 @@
>
>   obj-$(CONFIG_SAMPLES)	+= kobject/ kprobes/ trace_events/ livepatch/ \
>   			   hw_breakpoint/ kfifo/ kdb/ hidraw/ rpmsg/ seccomp/ \
> -			   configfs/
> +			   configfs/ bpf/
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 88bc5a0..bc5b675 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -2,23 +2,23 @@
>   obj- := dummy.o
>
>   # List of programs to build
> -hostprogs-y := test_verifier test_maps
> -hostprogs-y += sock_example
> -hostprogs-y += fds_example
> -hostprogs-y += sockex1
> -hostprogs-y += sockex2
> -hostprogs-y += sockex3
> -hostprogs-y += tracex1
> -hostprogs-y += tracex2
> -hostprogs-y += tracex3
> -hostprogs-y += tracex4
> -hostprogs-y += tracex5
> -hostprogs-y += tracex6
> -hostprogs-y += trace_output
> -hostprogs-y += lathist
> -hostprogs-y += offwaketime
> -hostprogs-y += spintest
> -hostprogs-y += map_perf_test
> +hostprogs-$(CONFIG_SAMPLE_BPF) := test_verifier test_maps
> +hostprogs-$(CONFIG_SAMPLE_BPF) += sock_example
> +hostprogs-$(CONFIG_SAMPLE_BPF) += fds_example
> +hostprogs-$(CONFIG_SAMPLE_BPF) += sockex1
> +hostprogs-$(CONFIG_SAMPLE_BPF) += sockex2
> +hostprogs-$(CONFIG_SAMPLE_BPF) += sockex3
> +hostprogs-$(CONFIG_SAMPLE_BPF) += tracex1
> +hostprogs-$(CONFIG_SAMPLE_BPF) += tracex2
> +hostprogs-$(CONFIG_SAMPLE_BPF) += tracex3
> +hostprogs-$(CONFIG_SAMPLE_BPF) += tracex4
> +hostprogs-$(CONFIG_SAMPLE_BPF) += tracex5
> +hostprogs-$(CONFIG_SAMPLE_BPF) += tracex6
> +hostprogs-$(CONFIG_SAMPLE_BPF) += trace_output
> +hostprogs-$(CONFIG_SAMPLE_BPF) += lathist
> +hostprogs-$(CONFIG_SAMPLE_BPF) += offwaketime
> +hostprogs-$(CONFIG_SAMPLE_BPF) += spintest
> +hostprogs-$(CONFIG_SAMPLE_BPF) += map_perf_test
>
>   test_verifier-objs := test_verifier.o libbpf.o
>   test_maps-objs := test_maps.o libbpf.o
> @@ -39,8 +39,8 @@ offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
>   spintest-objs := bpf_load.o libbpf.o spintest_user.o
>   map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
>
> -# Tell kbuild to always build the programs
> -always := $(hostprogs-y)
> +ifdef CONFIG_SAMPLE_BPF
> +always := $(hostprogs-$(CONFIG_SAMPLE_BPF))
>   always += sockex1_kern.o
>   always += sockex2_kern.o
>   always += sockex3_kern.o
> @@ -56,6 +56,7 @@ always += lathist_kern.o
>   always += offwaketime_kern.o
>   always += spintest_kern.o
>   always += map_perf_test_kern.o
> +endif
>
>   HOSTCFLAGS += -I$(objtree)/usr/include
>
>
