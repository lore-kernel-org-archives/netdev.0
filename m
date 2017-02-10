From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next v5 10/11] bpf: Remove bpf_sys.h from selftests
Date: Fri, 10 Feb 2017 10:30:13 +0800
Message-ID: <828ab1ff-4dcf-53ff-c97b-074adb895006@huawei.com>
References: <20170209232145.19085-1-mic@digikod.net>
 <20170209232145.19085-11-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209232145.19085-11-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/2/10 7:21, Mickaël Salaün wrote:
> Add require dependency headers.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Shuah Khan <shuah@kernel.org>
> ---
>   tools/lib/bpf/bpf.c                         |  6 ++++++
>   tools/testing/selftests/bpf/bpf_sys.h       | 27 ---------------------------
>   tools/testing/selftests/bpf/test_lpm_map.c  |  1 -
>   tools/testing/selftests/bpf/test_lru_map.c  |  1 -
>   tools/testing/selftests/bpf/test_maps.c     |  1 -
>   tools/testing/selftests/bpf/test_tag.c      |  3 +--
>   tools/testing/selftests/bpf/test_verifier.c |  4 ++--
>   7 files changed, 9 insertions(+), 34 deletions(-)
>   delete mode 100644 tools/testing/selftests/bpf/bpf_sys.h
>
> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
> index f8a2b7fa7741..50e04cc5dddd 100644
> --- a/tools/lib/bpf/bpf.c
> +++ b/tools/lib/bpf/bpf.c
> @@ -50,7 +50,13 @@ static __u64 ptr_to_u64(const void *ptr)
>   static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
>   		   unsigned int size)
>   {
> +#ifdef __NR_bpf
>   	return syscall(__NR_bpf, cmd, attr, size);
> +#else
> +	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
> +	errno = ENOSYS;
> +	return -1;
> +#endif
>   }
>   

We don't need check __NR_bpf again. It has already
been checked at the header of this file:

#ifndef __NR_bpf
# if defined(__i386__)
#  define __NR_bpf 357
# elif defined(__x86_64__)
#  define __NR_bpf 321
# elif defined(__aarch64__)
#  define __NR_bpf 280
# else
#  error __NR_bpf not defined. libbpf does not support your arch.
# endif
#endif

Thank you.
