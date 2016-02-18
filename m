From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC][PATCH 00/10] Add trace event support to eBPF
Date: Thu, 18 Feb 2016 23:40:23 +0100
Message-ID: <56C64857.1090502@iogearbox.net>
References: <cover.1455291671.git.tom.zanussi@linux.intel.com>	 <20160214000236.GA16236@ast-mbp.kubiwireless.com>	 <1455662127.2641.157.camel@tzanussi-mobl.amr.corp.intel.com>	 <20160217045103.GA47275@ast-mbp.thefacebook.com> <1455830838.14359.58.camel@tzanussi-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com,
	namhyung@kernel.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom Zanussi <tom.zanussi@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455830838.14359.58.camel@tzanussi-mobl.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2016 10:27 PM, Tom Zanussi wrote:
> On Tue, 2016-02-16 at 20:51 -0800, Alexei Starovoitov wrote:
>> On Tue, Feb 16, 2016 at 04:35:27PM -0600, Tom Zanussi wrote:
>>> On Sun, 2016-02-14 at 01:02 +0100, Alexei Starovoitov wrote:
[...]
>>>> Take a look at all the tools written on top of it:
>>>> https://github.com/iovisor/bcc/tree/master/tools
>>>
>>> That's great, but it's all out-of-tree.  Supporting out-of-tree users
>>> has never been justification for merging in-kernel code (or for blocking
>>> it from being merged).
>>
>> huh? perf is the only in-tree user space project.
>> All others tools and libraries are out-of-tree and that makes sense.
>
> What about all the other things under tools/?
>
>> Actually would be great to merge bcc with perf eventually, but choice
>> of C++ isn't going to make it easy. The only real difference
>> between perf+bpf and bcc is that bcc integrates clang/llvm
>> as a library whereas perf+bpf deals with elf files and standalone compiler.
>> There are pros and cons for both and it's great that both are actively
>> growing and gaining user traction.
>
> Why worry about merging bcc with perf?  Why not a tools/bcc?

It would indeed be great to mid-term have bcc internals to some degree
merged(/rewritten) into perf. tools/bcc doesn't make much sense to me
as it really should be perf, where already the rest of the eBPF front-end
logic resides that Wang et al initially integrated. So efforts could
consolidate from that side.

The user could be given a choice whether his use-case is to load the
object file, or directly pass in a C file where perf does the rest. And
f.e. Brendan's tools could ship natively as perf "built-ins" that users
can go and try out from there directly and/or use the code as a starting
point for their own proglets.

Cheers,
Daniel
