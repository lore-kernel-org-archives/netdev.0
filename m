From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH V3 2/5] samples/bpf: Makefile verify LLVM
 compiler avail and bpf target is supported
Date: Wed, 27 Apr 2016 14:24:48 +0530
Message-ID: <20160427085447.GB15073@naverao1-tp.in.ibm.com>
References: <20160427072855.29959.70252.stgit@firesoul>
 <20160427073018.29959.57913.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([125.16.236.1]:47248 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbcD0IzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 04:55:03 -0400
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Wed, 27 Apr 2016 14:24:59 +0530
Content-Disposition: inline
In-Reply-To: <20160427073018.29959.57913.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/04/27 09:30AM, Jesper Dangaard Brouer wrote:
> Make compiling samples/bpf more user friendly, by detecting if LLVM
> compiler tool 'llc' is available, and also detect if the 'bpf' target
> is available in this version of LLVM.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  samples/bpf/Makefile |   18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)

Acked-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 5bae9536f100..45859c99f573 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -85,6 +85,24 @@ HOSTLOADLIBES_test_overhead += -lelf -lrt
>  #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
>  LLC ?= llc
> 
> +# Verify LLVM compiler is available and bpf target is supported
> +.PHONY: verify_cmd_llc verify_target_bpf
> +
> +verify_cmd_llc:
> +	@if ! (which "${LLC}" > /dev/null 2>&1); then \
> +		echo "*** ERROR: Cannot find LLVM tool 'llc' (${LLC})" ;\
> +		exit 1; \
> +	else true; fi
> +
> +verify_target_bpf: verify_cmd_llc
> +	@if ! (${LLC} -march=bpf -mattr=help > /dev/null 2>&1); then \
> +		echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' target" ;\
> +		echo "   NOTICE: LLVM version >= 3.7.1 required" ;\
> +		exit 2; \
> +	else true; fi
> +
> +$(src)/*.c: verify_target_bpf
> +
>  # asm/sysreg.h - inline assembly used by it is incompatible with llvm.
>  # But, there is no easy way to fix it, so just exclude it since it is
>  # useless for BPF samples.
> 
