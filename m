From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] bpf: split eBPF out of NET
Date: Fri, 24 Oct 2014 10:37:01 +0200
Message-ID: <544A0FAD.1030202@redhat.com>
References: <1414114868-28228-1-git-send-email-ast@plumgrid.com> <20141024032355.GB7879@thin> <CAMEtUuxsk=iLDsD4XXZ8EcurFXgFxD-9iePv=NbBZn+b3YOXJA@mail.gmail.com> <20141024081139.GA8861@thin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, yann.morin.1998@free.fr
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141024081139.GA8861@thin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/2014 10:11 AM, Josh Triplett wrote:
> On Thu, Oct 23, 2014 at 10:32:50PM -0700, Alexei Starovoitov wrote:
>> On Thu, Oct 23, 2014 at 8:23 PM, Josh Triplett <josh@joshtriplett.org> wrote:
>>> On Thu, Oct 23, 2014 at 06:41:08PM -0700, Alexei Starovoitov wrote:
>>>> introduce two configs:
>>>> - hidden CONFIG_BPF to select eBPF interpreter that classic socket filters
>>>>    depend on
>>>> - visible CONFIG_BPF_SYSCALL (default off) that tracing and sockets can use
>>>>
>>>> that solves several problems:
>>>> - tracing and others that wish to use eBPF don't need to depend on NET.
>>>>    They can use BPF_SYSCALL to allow loading from userspace or select BPF
>>>>    to use it directly from kernel in NET-less configs.
>>>> - in 3.18 programs cannot be attached to events yet, so don't force it on
>>>> - when the rest of eBPF infra is there in 3.19+, it's still useful to
>>>>    switch it off to minimize kernel size
>>>>
>>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>>
>>> Thanks for working on this!  A few nits below, but otherwise this looks
>>> good to me.  Once this gets appropriate reviews from net and bpf folks,
>>> please let me know if you want this to go through the net tree, the tiny
>>> tree, or some other tree.
>>
>> Thanks :)
>> I've sent it to Dave and marked it as 'net', so it's for
>> his net tree. I don't mind if he decides to steer it into net-next
>> when it opens, since changing Kconfig is always tricky.
>> I just felt that this patch deserves to be in 'net' and in 3.18-rc
>
> Ah, nice; yes, getting it into 3.18-rc would be excellent if possible.

Fully agreed, BPF_SYSCALL defaulting to 'n' _for the time being_
would also give an option for reducing exposure until the API is
further stabilized and in a ready-to-use state.

>>>> bloat-o-meter on x64 shows:
>>>> add/remove: 0/60 grow/shrink: 0/2 up/down: 0/-15601 (-15601)
>>>
>>> Very nice!  Please do include the bloat-o-meter stats in the commit
>>> message.
>>
>> I don't think that's necessary. eBPF is in early stages of adoption.
>> More things to come, so bloat-o-meter stats will be obsolete
>> very quickly.
>
> I don't mean the full list of symbols, just the summary saying this
> saves 15k.

It might probably help to more easily identify from the log which
commits are related to a tinyfication perspective. Perhaps Dave can
still squash that into the commit log.

>>>> +# interpreter that classic socket filters depend on
>>>> +config BPF
>>>> +     boolean
>>>
>>> s/boolean/bool/
>>
>> Is there a difference? I thought it's an alias.
>
> It's an alias, but almost everything uses "bool":
>
> ~/src/linux$ git grep -w bool -- '*Kconfig*' | wc -l
> 7064
> ~/src/linux$ git grep -w boolean -- '*Kconfig*' | wc -l
> 94

Actually, shouldn't we get rid of the alias then? Same accounts
for def_bool and def_boolean ... it would help to avoid confusion
to just have a single term for each.

Anyway, the rest looks good to me, thanks.

I am totally fine of having it under EXPERT for now for the reasons
mentioned above. This can still be lifted later on.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
