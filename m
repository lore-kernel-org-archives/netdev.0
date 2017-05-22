From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/2] samples/bpf: add samples for HW_CACHE / RAW
 events
Date: Mon, 22 May 2017 16:35:07 -0700
Message-ID: <63c0ec55-9cb7-50a0-2020-fe17283e532b@fb.com>
References: <20170522224840.810121-1-ast@fb.com>
 <20170522224840.810121-3-ast@fb.com>
 <20170522.192651.252662920166760334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peterz@infradead.org>, <bgregg@netflix.com>,
        <daniel@iogearbox.net>, <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522.192651.252662920166760334.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/22/17 4:26 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Mon, 22 May 2017 15:48:40 -0700
>
>> @@ -31,7 +31,7 @@ static unsigned long long (*bpf_get_current_uid_gid)(void) =
>>  	(void *) BPF_FUNC_get_current_uid_gid;
>>  static int (*bpf_get_current_comm)(void *buf, int buf_size) =
>>  	(void *) BPF_FUNC_get_current_comm;
>> -static int (*bpf_perf_event_read)(void *map, int index) =
>> +static u64 (*bpf_perf_event_read)(void *map, u64 flags) =
>>  	(void *) BPF_FUNC_perf_event_read;
>
> If the second argument really is "u64 flags", then please update
> the comments in tools/include/uapi/linux/bpf.h as well.

of course.
As independent patch, I assume.
For both tools/include/uapi/...bpf.h and include/uapi/...bpf.h

It has some info:
/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
#define BPF_F_INDEX_MASK                0xffffffffULL
#define BPF_F_CURRENT_CPU               BPF_F_INDEX_MASK

yet perf_event_read() is least documented. hmm.
  * u64 bpf_perf_event_read(&map, index)
  *     Return: Number events read or error code

that needs to be fixed.
