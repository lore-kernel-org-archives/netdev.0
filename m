From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next v5 04/11] bpf: Use bpf_load_program() from the
 library
Date: Fri, 10 Feb 2017 10:39:31 +0800
Message-ID: <e29f46d0-cf3a-6d52-ccc4-53efeed6c2a9@huawei.com>
References: <20170209232145.19085-1-mic@digikod.net>
 <20170209232145.19085-5-mic@digikod.net>
 <2ffd3f6b-ee07-af83-ced3-bad5e4e35cc8@huawei.com>
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
In-Reply-To: <2ffd3f6b-ee07-af83-ced3-bad5e4e35cc8@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/2/10 10:25, Wangnan (F) wrote:
>
>
> On 2017/2/10 7:21, Mickaël Salaün wrote:
>> Replace bpf_prog_load() with bpf_load_program() calls.
>>
>> Signed-off-by: Mickaël Salaün <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Shuah Khan <shuah@kernel.org>
>> ---
>>   tools/lib/bpf/bpf.c                         |  6 +++---
>>   tools/lib/bpf/bpf.h                         |  4 ++--
>>   tools/testing/selftests/bpf/Makefile        |  4 +++-
>>   tools/testing/selftests/bpf/bpf_sys.h       | 21 ---------------------
>>   tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
>>   tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
>>   6 files changed, 17 insertions(+), 32 deletions(-)
>>
>> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
>> index 3ddb58a36d3c..58ce252073fa 100644
>> --- a/tools/lib/bpf/bpf.c
>> +++ b/tools/lib/bpf/bpf.c
>> @@ -42,7 +42,7 @@
>>   # endif
>>   #endif
>>   -static __u64 ptr_to_u64(void *ptr)
>> +static __u64 ptr_to_u64(const void *ptr)
>>   {
>>       return (__u64) (unsigned long) ptr;
>>   }
>> @@ -69,8 +69,8 @@ int bpf_create_map(enum bpf_map_type map_type, int 
>> key_size,
>>       return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
>>   }
>>   -int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
>> -             size_t insns_cnt, char *license,
>> +int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn 
>> *insns,
>> +             size_t insns_cnt, const char *license,
>>                __u32 kern_version, char *log_buf, size_t log_buf_sz)
>>   {
>>       int fd;
>> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
>> index a2f9853dd882..bc959a2de023 100644
>> --- a/tools/lib/bpf/bpf.h
>> +++ b/tools/lib/bpf/bpf.h
>> @@ -28,8 +28,8 @@ int bpf_create_map(enum bpf_map_type map_type, int 
>> key_size, int value_size,
>>     /* Recommend log buffer size */
>>   #define BPF_LOG_BUF_SIZE 65536
>> -int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
>> -             size_t insns_cnt, char *license,
>> +int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn 
>> *insns,
>> +             size_t insns_cnt, const char *license,
>>                __u32 kern_version, char *log_buf,
>>                size_t log_buf_sz);
>
> For libbpf changes:

And for similar code in patch 5-8:

Acked-by Wang Nan <wangnan0@huawei.com>

Thank you.
>
> Acked-by Wang Nan <wangnan0@huawei.com>
>
> Thank you.
