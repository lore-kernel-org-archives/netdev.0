From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next 1/3] bpf: introduce current->pid, tgid, uid, gid,
 comm accessors
Date: Fri, 12 Jun 2015 17:24:53 -0700
Message-ID: <CALCETrWUuoZz2XOox5FJJPAfFdBakLnY1d7LLP5Uxq9tqgkpzg@mail.gmail.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com>
 <1434145226-17892-2-git-send-email-ast@plumgrid.com> <CALCETrUidQ9ig-xZrAFX8_==aVbDNKU-GfeYNMsT6uHugqSydg@mail.gmail.com>
 <557B60DB.5030200@plumgrid.com> <CALCETrVCAZkoM2TsrxgeT7d+kWjLrcRt76wiPav1Fk7wz0z-3g@mail.gmail.com>
 <557B6A00.7000600@plumgrid.com> <CALCETrVnhCoD9=nzDpB6UvmXyGz4Th_m1fstJDyRUKzfsSaKHw@mail.gmail.com>
 <557B6D74.2070305@plumgrid.com> <CALCETrU0OKoWKgxzUyi9A88Pm1VDfiCmgwbNycZoGbiHa6PzWA@mail.gmail.com>
 <557B718B.80604@plumgrid.com> <CALCETrWYHkBtVr5D0zdrXswoH2gSXsxhtD23w6J7EP=HEwPt8A@mail.gmail.com>
 <557B763F.7000003@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>, Li Zefan <lizefan@huawei.com>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:34036 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbbFMAZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 20:25:16 -0400
Received: by lagv1 with SMTP id v1so160571lag.1
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 17:25:14 -0700 (PDT)
In-Reply-To: <557B763F.7000003@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 5:15 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 6/12/15 5:03 PM, Andy Lutomirski wrote:
>>
>> On Fri, Jun 12, 2015 at 4:55 PM, Alexei Starovoitov <ast@plumgrid.com>
>> wrote:
>>>
>>> On 6/12/15 4:47 PM, Andy Lutomirski wrote:
>>>>
>>>>
>>>> On Fri, Jun 12, 2015 at 4:38 PM, Alexei Starovoitov <ast@plumgrid.com>
>>>> wrote:
>>>>>
>>>>>
>>>>> On 6/12/15 4:25 PM, Andy Lutomirski wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> It's a dangerous tool.  Also, shouldn't the returned uid match the
>>>>>> namespace of the task that installed the probe, not the task that's
>>>>>> being probed?
>>>>>
>>>>>
>>>>>
>>>>>
>>>>> so leaking info to unprivileged apps is the concern?
>>>>> The whole thing is for root only as you know.
>>>>> The non-root is still far away. Today root needs to see the whole
>>>>> kernel. That was the goal from the beginning.
>>>>>
>>>>
>>>> This is more of a correctness issue than a security issue.  ISTM using
>>>> current_user_ns() in a kprobe is asking for trouble.  It certainly
>>>> allows any unprivilege user to show any uid it wants to the probe,
>>>> which is probably not what the installer of the probe expects.
>>>
>>>
>>>
>>> probe doesn't expect anything. it doesn't make any decisions.
>>> bpf is read only. it's _visibility_ into the kernel.
>>> It's not used for security.
>>> When we start connecting eBPF to seccomp I would agree that uid
>>> handling needs to be done carefully, but we're not there yet.
>>> I don't want to kill _visibility_ because in some distant future
>>> bpf becomes a decision making tool in security area and
>>> get_current_uid() will return numbers that shouldn't be blindly
>>> used to reject/accept a user requesting something. That's far away.
>>>
>>
>> All that is true, but the code that *installed* the bpf probe might
>> get might confused when it logs that uid 0 did such-and-such when
>> really some unprivileged userns root did it.
>
>
> so what specifically you proposing?
> Use from_kuid(&init_user_ns,...) instead?

That seems reasonable to me.  After all, you can't install one of
these probes from a non-init userns.

--Andy
