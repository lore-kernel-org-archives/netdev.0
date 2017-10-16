From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 3/3] bpf: Make sure that ->comm does not change under
 us.
Date: Mon, 16 Oct 2017 23:02:06 +0200
Message-ID: <59E51E4E.4060009@iogearbox.net>
References: <20171016181856.12497-1-richard@nod.at> <20171016181856.12497-3-richard@nod.at> <59E51BA3.8040106@iogearbox.net> <3636052.F7cf4ubS1t@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3636052.F7cf4ubS1t@blindfold>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2017 10:55 PM, Richard Weinberger wrote:
> Am Montag, 16. Oktober 2017, 22:50:43 CEST schrieb Daniel Borkmann:
>>>    	struct task_struct *task = current;
>>>
>>> +	task_lock(task);
>>>
>>>    	strncpy(buf, task->comm, size);
>>>
>>> +	task_unlock(task);
>>
>> Wouldn't this potentially lead to a deadlock? E.g. you attach yourself
>> to task_lock() / spin_lock() / etc, and then the BPF prog triggers the
>> bpf_get_current_comm() taking the lock again ...
>
> Yes, but doesn't the same apply to the use case when I attach to strncpy()
> and run bpf_get_current_comm()?

You mean due to recursion? In that case trace_call_bpf() would bail out
due to the bpf_prog_active counter.
