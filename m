From: Topi Miettinen <toiwoton@gmail.com>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
Date: Fri, 15 Jul 2016 16:57:00 +0000
Message-ID: <485128c4-61c6-45ac-7ae2-2d4819697ec4@gmail.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715124330.GR30154@twins.programming.kicks-ass.net>
 <28b4b919-4f50-d9f6-c5e1-d1e92ea1ba1c@gmail.com>
 <20160715135956.GA3115@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>,
 Radim Kr??m???? <rkrcmar@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
 Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>,
 Hal Rosenstock <hal.rosenstock@gmail.com>,
 Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>,
 Sudeep Dutt <sudeep.dutt@intel.com>,
 Ashutosh Dixit <ashut
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160715135956.GA3115@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 07/15/16 13:59, Peter Zijlstra wrote:
> On Fri, Jul 15, 2016 at 01:52:48PM +0000, Topi Miettinen wrote:
>> On 07/15/16 12:43, Peter Zijlstra wrote:
>>> On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
>>>> Hello,
>>>>
>>>> There are many basic ways to control processes, including capabilities,
>>>> cgroups and resource limits. However, there are far fewer ways to find out
>>>> useful values for the limits, except blind trial and error.
>>>>
>>>> This patch series attempts to fix that by giving at least a nice starting
>>>> point from the highwater mark values of the resources in question.
>>>> I looked where each limit is checked and added a call to update the mark
>>>> nearby.
>>>
>>> And how is that useful? Setting things to the high watermark is
>>> basically the same as not setting the limit at all.
>>
>> What else would you use, too small limits?
> 
> That question doesn't make sense.
> 
> What's the point of setting a limit if it ends up being the same as
> no-limit (aka unlimited).

Having a limit is not the same as not having any limits at all. You're
in a way right that good limits don't affect the program normally. But
they can make a difference if the flow is not normal. For example a
successful exploit or a memory leak bug could cause RLIMIT_AS to trigger.

> 
> If you cannot explain; and you have not so far; what use these values
> are, why would we look at the patches.
> 

The use case is to allow system administrators, distro maintainers and
developers to configure systems to use the resource limits. The limits
are not very useful right now, as there is no way to figure out what
values to use. There are a few /proc files to look, for example current
number of file descriptors (for RLIMIT_NOFILE) could be counted via
/proc/pid/fd. But now there is no way to know if there were more in use
at some point. Likewise, a program can use more address space when you
are not looking. The source code does not tell these things explicitly.

-Topi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
