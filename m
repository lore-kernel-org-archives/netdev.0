From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 04/11] bpf: Use bpf_load_program() from the
 library
Date: Thu, 09 Feb 2017 22:05:39 +0100
Message-ID: <589CD9A3.9030206@iogearbox.net>
References: <20170208204940.26023-1-mic@digikod.net> <20170208204940.26023-5-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208204940.26023-5-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/2017 09:49 PM, Mickaël Salaün wrote:
> Replace bpf_prog_load() with bpf_load_program() calls.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Shuah Khan <shuah@kernel.org>
[...]
> diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
> index 5f7c602f47d1..b77dc4b03e77 100644
> --- a/tools/testing/selftests/bpf/test_tag.c
> +++ b/tools/testing/selftests/bpf/test_tag.c
> @@ -16,6 +16,8 @@
>   #include <linux/bpf.h>
>   #include <linux/if_alg.h>
>
> +#include <bpf/bpf.h>
> +
>   #include "../../../include/linux/filter.h"
>
>   #include "bpf_sys.h"
> @@ -55,8 +57,8 @@ static int bpf_try_load_prog(int insns, int fd_map,
>   	int fd_prog;
>
>   	bpf_filler(insns, fd_map);
> -	fd_prog = bpf_prog_load(BPF_PROG_TYPE_SCHED_CLS, prog, insns *
> -				sizeof(struct bpf_insn), "", NULL, 0);
> +	fd_prog = bpf_load_program(BPF_PROG_TYPE_SCHED_CLS, prog, insns, "", 0,
> +			NULL, 0);

Went over the set and generally looks good. Please make sure though,
like in above case that you properly fix aligning next line to the
opening '('. I've noticed this multiple times in this and in the next
patch at least. Please double check the rest of your series as well.

Thanks,
Daniel
