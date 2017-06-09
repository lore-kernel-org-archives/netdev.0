From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next 2/2] bpf: Fix test_obj_id.c for llvm 5.0
Date: Fri, 9 Jun 2017 08:40:18 -0700
Message-ID: <779242ce-1fc8-deeb-8eb0-27ed74161186@fb.com>
References: <20170609053017.2909855-1-kafai@fb.com>
 <20170609053017.2909855-2-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45292 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751534AbdFIPkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 11:40:39 -0400
In-Reply-To: <20170609053017.2909855-2-kafai@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/8/17 10:30 PM, Martin KaFai Lau wrote:
> llvm 5.0 does not like the section name and the function name
> to be the same:
> 
> clang -I. -I./include/uapi -I../../../include/uapi \
> 	-I../../../../samples/bpf/ \
> 	-Wno-compare-distinct-pointer-types \
> 	-O2 -target bpf -c \
> 	linux/tools/testing/selftests/bpf/test_obj_id.c -o \
> 	linux/tools/testing/selftests/bpf/test_obj_id.o
> fatal error: error in backend: 'test_prog_id' label emitted multiple times to
> assembly file
> clang-5.0: error: clang frontend command failed with exit code 70 (use -v to
> see invocation)
> clang version 5.0.0 (trunk 304326) (llvm/trunk 304329)
> 
> This patch makes changes to the section name and the function name.
> 
> Fixes: 95b9afd3987f ("bpf: Test for bpf ID")
> Reported-by: Alexei Starovoitov <ast@fb.com>
> Reported-by: Yonghong Song <yhs@fb.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   tools/testing/selftests/bpf/test_obj_id.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/testing/selftests/bpf/test_obj_id.c b/tools/testing/selftests/bpf/test_obj_id.c
> index d8723aaf827a..880d2963b472 100644
> --- a/tools/testing/selftests/bpf/test_obj_id.c
> +++ b/tools/testing/selftests/bpf/test_obj_id.c
> @@ -23,8 +23,8 @@ struct bpf_map_def SEC("maps") test_map_id = {
>   	.max_entries = 1,
>   };
>   
> -SEC("test_prog_id")
> -int test_prog_id(struct __sk_buff *skb)
> +SEC("test_obj_id_dummy")
> +int test_obj_id(struct __sk_buff *skb)
>   {
>   	__u32 key = 0;
>   	__u64 *value;
> 
Acked-by: Yonghong Song <yhs@fb.com>
