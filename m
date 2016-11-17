From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv2 perf/core 2/2] tools lib bpf: Sync with
 samples/bpf/libbpf
Date: Thu, 17 Nov 2016 11:21:06 +0800
Message-ID: <582D2222.4060309@huawei.com>
References: <20161116174324.29675-1-joe@ovn.org>
 <20161116174324.29675-3-joe@ovn.org> <582D11B0.80208@huawei.com>
 <CAOftzPhXk0LKCt8wQKuqeBnDrj6a4p0YL7P80jhK78eFSAz8WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <acme@kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOftzPhXk0LKCt8wQKuqeBnDrj6a4p0YL7P80jhK78eFSAz8WQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/11/17 10:46, Joe Stringer wrote:
> On 16 November 2016 at 18:10, Wangnan (F) <wangnan0@huawei.com> wrote:
>> I'm also working on improving bpf.c. Please have a look at:
>>
>> https://lkml.org/lkml/2016/11/14/1078
>>
>> Since bpf.c is simple, I think we can add more functions and fixes
>> gradually, instead of a full copy.
>>
>> See my inline comment below.
> Ah, I missed this, my apologies. It looks like it will provide much of
> what I need, I can reassess this patch with your series in mind.
>
> One comment though for your patch (I don't have the original thread to
> respond to unfortunately): The map_pin and map_get functions in your
> patch series can be used to pin progs too, so maybe there is a better
> name? You'll see that this patch uses bpf_obj_{pin,get}() - although I
> wouldn't want those to be confused with the libbpf.c objects so maybe
> there's a clearer name that could be used.

The full thread can be found:

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1272045.html

(lkml.kernel.org is not working for me, sorry)

In that patch set, bpf_map_pin/get is linked into perf hooks, so BPF script
can pin a map to sysfs. I think this feature would be useful, but I don't
have an example to show how to use it. I didn't provide program pinning/get
interface because in perf hook they are not useful. After rethinking your
suggestion now I think it is okay to provide bpf_obj_{pin,get} in bpf.c
and export bpf_map_pin to perf hook. I'll adjust my own patch.

> I also have some patches to rework the samples/bpf/* code to use
> libbpf instead of the sample code that is there, is it worth me
> submitting that? It will need to wait for your patch to go in, plus a
> merge with davem's tree.
>
>> On 2016/11/17 1:43, Joe Stringer wrote:

[SNIP]

>>>    /*
>>> @@ -53,24 +60,71 @@ static int sys_bpf(enum bpf_cmd cmd, union bpf_attr
>>> *attr,
>>>          return syscall(__NR_bpf, cmd, attr, size);
>>>    }
>>>    -int bpf_create_map(enum bpf_map_type map_type, int key_size,
>>> -                  int value_size, int max_entries)
>>> +int bpf_create_map(enum bpf_map_type map_type, int key_size, int
>>> value_size,
>>> +                  int max_entries, int map_flags)
>>>    {
>>> -       union bpf_attr attr;
>>> +       union bpf_attr attr = {
>>> +               .map_type = map_type,
>>> +               .key_size = key_size,
>>> +               .value_size = value_size,
>>> +               .max_entries = max_entries,
>>> +               .map_flags = map_flags,
>>> +       };
>>>    -     memset(&attr, '\0', sizeof(attr));
>>> +       return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
>>> +}
>>>
>>
>> I lost map_flags in original bpf.c. Thanks to your patch. map_flags is
>> useful
>> when creating BPF_MAP_TYPE_PERCPU_HASH: BPF_F_NO_PREALLOC is meanful in this
>> case.
> Do you want me to resubmit this piece as a separate patch or will you
> address this?

Please send it.

Thank you.
