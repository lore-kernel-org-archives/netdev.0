From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next 1/3] bpf: introduce current->pid, tgid, uid, gid,
 comm accessors
Date: Fri, 12 Jun 2015 16:47:06 -0700
Message-ID: <CALCETrU0OKoWKgxzUyi9A88Pm1VDfiCmgwbNycZoGbiHa6PzWA@mail.gmail.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com>
 <1434145226-17892-2-git-send-email-ast@plumgrid.com> <CALCETrUidQ9ig-xZrAFX8_==aVbDNKU-GfeYNMsT6uHugqSydg@mail.gmail.com>
 <557B60DB.5030200@plumgrid.com> <CALCETrVCAZkoM2TsrxgeT7d+kWjLrcRt76wiPav1Fk7wz0z-3g@mail.gmail.com>
 <557B6A00.7000600@plumgrid.com> <CALCETrVnhCoD9=nzDpB6UvmXyGz4Th_m1fstJDyRUKzfsSaKHw@mail.gmail.com>
 <557B6D74.2070305@plumgrid.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <557B6D74.2070305@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 12, 2015 at 4:38 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 6/12/15 4:25 PM, Andy Lutomirski wrote:
>>
>> It's a dangerous tool.  Also, shouldn't the returned uid match the
>> namespace of the task that installed the probe, not the task that's
>> being probed?
>
>
> so leaking info to unprivileged apps is the concern?
> The whole thing is for root only as you know.
> The non-root is still far away. Today root needs to see the whole
> kernel. That was the goal from the beginning.
>

This is more of a correctness issue than a security issue.  ISTM using
current_user_ns() in a kprobe is asking for trouble.  It certainly
allows any unprivilege user to show any uid it wants to the probe,
which is probably not what the installer of the probe expects.

--Andy
