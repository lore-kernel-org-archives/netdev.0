From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH V2 2/2] bpf: control a set of perf events by creating
 a new ioctl PERF_EVENT_IOC_SET_ENABLER
Date: Thu, 15 Oct 2015 10:21:17 +0800
Message-ID: <561F0D9D.4000205@huawei.com>
References: <1444826277-94060-1-git-send-email-xiakaixu@huawei.com> <1444826277-94060-3-git-send-email-xiakaixu@huawei.com> <561EC917.8090001@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<a.p.zijlstra@chello.nl>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561EC917.8090001@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/10/15 5:28, Alexei Starovoitov =E5=86=99=E9=81=93:
> On 10/14/15 5:37 AM, Kaixu Xia wrote:
>> +    event->p_sample_disable =3D &enabler_event->sample_disable;
>=20
> I don't like it as a concept and it's buggy implementation.
> What happens here when enabler is alive, but other event is destroyed=
?
>=20
>> --- a/kernel/trace/bpf_trace.c
>> +++ b/kernel/trace/bpf_trace.c
>> @@ -221,9 +221,12 @@ static u64 bpf_perf_event_sample_control(u64 r1=
, u64 index, u64 flag, u64 r4, u6
>>       struct bpf_array *array =3D container_of(map, struct bpf_array=
, map);
>>       struct perf_event *event;
>>
>> -    if (unlikely(index >=3D array->map.max_entries))
>> +    if (unlikely(index > array->map.max_entries))
>>           return -E2BIG;
>>
>> +    if (index =3D=3D array->map.max_entries)
>> +        index =3D 0;
>=20
> what is this hack for ?
>=20
> Either use notification and user space disable or
> call bpf_perf_event_sample_control() manually for each cpu.

I will discard current implemention that controlling a set of
perf events by the 'enabler' event. Call bpf_perf_event_sample_control(=
)
manually for each cpu is fine. Maybe we can add a loop to control all t=
he
events stored in maps by judging the index, OK?
>=20
>=20
>=20
> .
>=20
