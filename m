From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv3 perf/core 5/7] samples/bpf: Switch over to libbpf
Date: Fri, 9 Dec 2016 13:18:20 +0800
Message-ID: <77ff1746-6271-0eac-a921-bb852c14a602@huawei.com>
References: <20161209024620.31660-1-joe@ovn.org>
 <20161209024620.31660-6-joe@ovn.org>
 <c256e266-14c0-d546-cf61-264035ed6282@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>, <acme@kernel.org>,
        <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c256e266-14c0-d546-cf61-264035ed6282@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/12/9 13:04, Wangnan (F) wrote:
>
>
> On 2016/12/9 10:46, Joe Stringer wrote:
>
> [SNIP]
>
>>   diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
>> index 62d89d50fcbd..616bd55f3be8 100644
>> --- a/tools/lib/bpf/Makefile
>> +++ b/tools/lib/bpf/Makefile
>> @@ -149,6 +149,8 @@ CMD_TARGETS = $(LIB_FILE)
>>     TARGETS = $(CMD_TARGETS)
>>   +libbpf: all
>> +
>
> Why we need this? I tested this patch without it and it seems to work, 
> and
> this line causes an extra error:
>  $ pwd
>  /home/wn/kernel/tools/lib/bpf
>  $ make libbpf
>  ...
>  gcc -g -Wall -DHAVE_LIBELF_MMAP_SUPPORT -DHAVE_ELF_GETPHDRNUM_SUPPORT 
> -Wbad-function-cast -Wdeclaration-after-statement -Wformat-security 
> -Wformat-y2k -Winit-self -Wmissing-declarations -Wmissing-prototypes 
> -Wnested-externs -Wno-system-headers -Wold-style-definition -Wpacked 
> -Wredundant-decls -Wshadow -Wstrict-aliasing=3 -Wstrict-prototypes 
> -Wswitch-default -Wswitch-enum -Wundef -Wwrite-strings -Wformat 
> -Werror -Wall -fPIC -I. -I/home/wn/kernel-hydrogen/tools/include 
> -I/home/wn/kernel-hydrogen/tools/arch/x86/include/uapi 
> -I/home/wn/kernel-hydrogen/tools/include/uapi    libbpf.c all   -o libbpf
>  gcc: error: all: No such file or directory
>  make: *** [libbpf] Error 1
>
> Thank you.

It is not 'caused' by your patch. 'make libbpf' fails without
your change because it tries to build an executable from
libbpf.c, but main() is missing.

I think libbpf should never be used as a make target. Your
new dependency looks strange.

Thank you.
