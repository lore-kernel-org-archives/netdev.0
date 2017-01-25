From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv2 perf/core 5/7] tools lib bpf: Add bpf_program__pin()
Date: Wed, 25 Jan 2017 10:18:22 +0800
Message-ID: <b93c8045-7408-fb8d-f8a1-c0d11bdbc791@huawei.com>
References: <20170123011128.26534-1-joe@ovn.org>
 <20170123011128.26534-6-joe@ovn.org>
 <e24b0753-43ee-fad5-86c4-a3699caff05d@huawei.com>
 <921d83a9-aa44-acee-4fcf-dbc45cc0a66a@huawei.com>
 <CAPWQB7EWFE6DToMwTws6rUpnO49UYV1Rq-=0KV2ZioUf+dTjpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:64110 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdAYCTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 21:19:31 -0500
In-Reply-To: <CAPWQB7EWFE6DToMwTws6rUpnO49UYV1Rq-=0KV2ZioUf+dTjpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/1/25 9:16, Joe Stringer wrote:
> On 24 January 2017 at 17:06, Wangnan (F) <wangnan0@huawei.com> wrote:
>>
>> On 2017/1/25 9:04, Wangnan (F) wrote:
>>>
>>>
>>> On 2017/1/23 9:11, Joe Stringer wrote:
>>>> Add a new API to pin a BPF program to the filesystem. The user can
>>>> specify the path full path within a BPF filesystem to pin the program.
>>>> Programs with multiple instances are pinned as 'foo', 'foo_1', 'foo_2',
>>>> and so on.
>>>>
>>>> Signed-off-by: Joe Stringer <joe@ovn.org>
>>>> ---
>>>> v2: Don't automount BPF filesystem
>>>>       Split program, map, object pinning into separate APIs and separate
>>>>       patches.
>>>> ---
>>
>> [SNIP]
>>
>>>> +int bpf_program__pin(struct bpf_program *prog, const char *path)
>>>
>>> In your next patch please let caller select one instance:
>>>
>>> int bpf_program__pin(struct bpf_program *prog, int instance, const char
>>> *path)
>>> (please choose a better name)
>>>
>>> Then your can wrap it with another function to pin all instances,
>>> implement
>>> naming schema (%s_%d) there.
>>>
>>> Then implement naming schema in bpf_object__pin like:
>>>
>>> %s/objectname_mapname
>>> %s/objectname_progname_%d
>>>
>> Is it possible to use directory tree instead?
>>
>> %s/object/mapname
>> %s/object/prog/instance
> I don't think objects have names, so let's assume an object with two
> program instances named foo, and one map named bar.
>
> A call of bpf_object__pin(obj, "/sys/fs/bpf/myobj") would mount with
> the following files and directories:
> /sys/fs/bpf/myobj/foo/1
> /sys/fs/bpf/myobj/foo/2
> /sys/fs/bpf/myobj/bar
>
> Alternatively, if you want to control exactly where you want the
> progs/maps to be pinned, you can call eg
> bpf_program__pin_instance(prog, "/sys/fs/bpf/wherever", 0) and that
> instance will be mounted to /sys/fs/bpf/wherever, or alternatively
> bpf_program__pin(prog, "/sys/fs/bpf/foo"), and you will end up with
> /sys/fs/bpf/foo/{0,1}.
>
> This looks pretty reasonable to me.

It looks good to me.

Thank you.
