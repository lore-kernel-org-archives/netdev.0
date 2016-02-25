From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/3] perf: generalize perf_callchain
Date: Thu, 25 Feb 2016 08:37:34 -0800
Message-ID: <56CF2DCE.5010501@fb.com>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-2-git-send-email-ast@fb.com>
 <20160225141859.GM6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160225141859.GM6357@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/25/16 6:18 AM, Peter Zijlstra wrote:
> On Wed, Feb 17, 2016 at 07:58:57PM -0800, Alexei Starovoitov wrote:
>> . avoid walking the stack when there is no room left in the buffer
>> . generalize get_perf_callchain() to be called from bpf helper
>
> If it does two things it should be two patches.

could have been two patches, but it will only add more churn
to the same lines. what's the concern?

>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>> ---
>>   arch/x86/include/asm/stacktrace.h |  2 +-
>>   arch/x86/kernel/cpu/perf_event.c  |  4 ++--
>>   arch/x86/kernel/dumpstack.c       |  6 ++++--
>>   arch/x86/kernel/stacktrace.c      | 18 +++++++++++-------
>>   arch/x86/oprofile/backtrace.c     |  3 ++-
>>   include/linux/perf_event.h        | 13 +++++++++++--
>>   kernel/events/callchain.c         | 32 ++++++++++++++++++++------------
>>   kernel/events/internal.h          |  2 --
>>   8 files changed, 51 insertions(+), 29 deletions(-)
>
> And at the very least this should have had a note that it doesn't break
> all the other archs that implement perf-callchain stuff.

the cross-arch interface is two weak functions
perf_callchain_kernel() and perf_callchain_user()
and back into generic via perf_callchain_store().
Nothing changes there. The code speaks for itself.
"non-x86 archs are not broken" would be a silly comment.
