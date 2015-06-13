From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] bpf: introduce current->pid, tgid, uid,
 gid, comm accessors
Date: Fri, 12 Jun 2015 17:15:59 -0700
Message-ID: <557B763F.7000003@plumgrid.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com> <1434145226-17892-2-git-send-email-ast@plumgrid.com> <CALCETrUidQ9ig-xZrAFX8_==aVbDNKU-GfeYNMsT6uHugqSydg@mail.gmail.com> <557B60DB.5030200@plumgrid.com> <CALCETrVCAZkoM2TsrxgeT7d+kWjLrcRt76wiPav1Fk7wz0z-3g@mail.gmail.com> <557B6A00.7000600@plumgrid.com> <CALCETrVnhCoD9=nzDpB6UvmXyGz4Th_m1fstJDyRUKzfsSaKHw@mail.gmail.com> <557B6D74.2070305@plumgrid.com> <CALCETrU0OKoWKgxzUyi9A88Pm1VDfiCmgwbNycZoGbiHa6PzWA@mail.gmail.com> <557B718B.80604@plumgrid.com> <CALCETrWYHkBtVr5D0zdrXswoH2gSXsxhtD23w6J7EP=HEwPt8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWYHkBtVr5D0zdrXswoH2gSXsxhtD23w6J7EP=HEwPt8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/12/15 5:03 PM, Andy Lutomirski wrote:
> On Fri, Jun 12, 2015 at 4:55 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> On 6/12/15 4:47 PM, Andy Lutomirski wrote:
>>>
>>> On Fri, Jun 12, 2015 at 4:38 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>>> wrote:
>>>>
>>>> On 6/12/15 4:25 PM, Andy Lutomirski wrote:
>>>>>
>>>>>
>>>>> It's a dangerous tool.  Also, shouldn't the returned uid match the
>>>>> namespace of the task that installed the probe, not the task that's
>>>>> being probed?
>>>>
>>>>
>>>>
>>>> so leaking info to unprivileged apps is the concern?
>>>> The whole thing is for root only as you know.
>>>> The non-root is still far away. Today root needs to see the whole
>>>> kernel. That was the goal from the beginning.
>>>>
>>>
>>> This is more of a correctness issue than a security issue.  ISTM using
>>> current_user_ns() in a kprobe is asking for trouble.  It certainly
>>> allows any unprivilege user to show any uid it wants to the probe,
>>> which is probably not what the installer of the probe expects.
>>
>>
>> probe doesn't expect anything. it doesn't make any decisions.
>> bpf is read only. it's _visibility_ into the kernel.
>> It's not used for security.
>> When we start connecting eBPF to seccomp I would agree that uid
>> handling needs to be done carefully, but we're not there yet.
>> I don't want to kill _visibility_ because in some distant future
>> bpf becomes a decision making tool in security area and
>> get_current_uid() will return numbers that shouldn't be blindly
>> used to reject/accept a user requesting something. That's far away.
>>
>
> All that is true, but the code that *installed* the bpf probe might
> get might confused when it logs that uid 0 did such-and-such when
> really some unprivileged userns root did it.

so what specifically you proposing?
Use from_kuid(&init_user_ns,...) instead?

> Also, as you start calling more and more non-trivial functions from
> bpf, you might need to start preventing bpf probe installations in
> those functions.

yes. may be. I don't want to blacklist stuff yet, unless it
causes crashes. Recursive check is already there. Probably
something else will be needed.
