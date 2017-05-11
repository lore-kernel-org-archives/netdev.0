From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Thu, 11 May 2017 15:58:33 -0700
Message-ID: <9afe8b73-806c-1511-dd26-f09e67b85107@fb.com>
References: <d809baa4-c864-af99-38af-fbcb6637ca2b@fb.com>
 <20170504.093723.1592226593887244452.davem@davemloft.net>
 <5d1d290b-7ff7-7f9d-15a0-599596e0778c@fb.com>
 <20170511.150246.650724054596949813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32790 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755287AbdEKW65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 18:58:57 -0400
In-Reply-To: <20170511.150246.650724054596949813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/17 12:02 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Thu, 4 May 2017 16:34:08 -0700
>
>> Hence I think the cleanest solution is to have bpf arch's types.h
>> either installed with llvm/gcc or picked from selftests's dir.
>
> Something like this?

yes :)
Ack.

> ====================
> [PATCH] bpf: Provide a linux/types.h override for bpf selftests.
>
> We do not want to use the architecture's type.h header when
> building BPF programs which are always 64-bit.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  tools/testing/selftests/bpf/Makefile                   | 3 ++-
>  tools/testing/selftests/bpf/include/uapi/linux/types.h | 6 ++++++
>  2 files changed, 8 insertions(+), 1 deletion(-)
>  create mode 100644 tools/testing/selftests/bpf/include/uapi/linux/types.h
>
> diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
> index f92f27d..f389b02 100644
> --- a/tools/testing/selftests/bpf/Makefile
> +++ b/tools/testing/selftests/bpf/Makefile
> @@ -35,6 +35,7 @@ $(BPFOBJ): force
>  CLANG ?= clang
>
>  %.o: %.c
> -	$(CLANG) -I. -I../../../include/uapi -I../../../../samples/bpf/ \
> +	$(CLANG) -I. -I./include/uapi -I../../../include/uapi \

Can we than move gnu/stubs.h into include/uapi as well and remove
the first -I. ?
Or keep them separate, since this linux/types.h is bpf's arch types.h
whereas gnu/stubs.h is a hack for glibc /usr/include/features.h ?
I'm fine whichever way including keeping this patch as-is.
