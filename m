From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: devmap: Check attr->max_entries more carefully
Date: Tue, 17 Oct 2017 12:32:38 +0200
Message-ID: <59E5DC46.70309@iogearbox.net>
References: <20171015220020.8157-1-richard@nod.at> <59E4FFDD.7010402@iogearbox.net> <20171017102935.5i4dqa7h44v4acft@lakrids.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@kernel.org, sp3485@columbia.edu,
        tj@kernel.org, john.fastabend@gmail.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171017102935.5i4dqa7h44v4acft@lakrids.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2017 12:29 PM, Mark Rutland wrote:
> On Mon, Oct 16, 2017 at 08:52:13PM +0200, Daniel Borkmann wrote:
>> [ +Tejun, Mark, John ]
>>
>> On 10/16/2017 12:00 AM, Richard Weinberger wrote:
>>> max_entries is user controlled and used as input for __alloc_percpu().
>>> This function expects that the allocation size is a power of two and
>>> less than PCPU_MIN_UNIT_SIZE.
>>> Otherwise a WARN() is triggered.
>>>
>>> Fixes: 11393cc9b9be ("xdp: Add batching support to redirect map")
>>> Reported-by: Shankara Pailoor <sp3485@columbia.edu>
>>> Reported-by: syzkaller <syzkaller@googlegroups.com>
>>> Signed-off-by: Richard Weinberger <richard@nod.at>
>>
>> Thanks for the patch, Richard. There was a prior discussion here [1] on
>> the same issue, I thought this would have been resolved by now, but looks
>> like it's still open and there was never a follow-up, at least I don't see
>> it in the percpu tree if I didn't miss anything.
>
> Sorry, this was on my todo list, but I've been bogged down with some
> other work.

Ok, no problem.

>> I would suggest, we do the following below and pass __GFP_NOWARN from BPF
>> side to the per-cpu allocs. This is kind of a generic 'issue' and we shouldn't
>> add more code which bails out anyway just to work around the WARN(). Lets
>> handle it properly instead.
>
> Agreed. The below patch looks good to me, (with the suggested change to
> the BPF side).
>
>> If Tejun is fine with the one below, I could cook and official patch and
>> cleanup the remaining call-sites from BPF which have similar pattern.
>
> That would be great; thanks for taking this on.

I'll prepare a set including BPF side for today.

Thanks,
Daniel
