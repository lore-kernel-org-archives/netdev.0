From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/3] perf: generalize perf_callchain
Date: Thu, 25 Feb 2016 15:18:59 +0100
Message-ID: <20160225141859.GM6357@twins.programming.kicks-ass.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-2-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33686 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760148AbcBYOTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:19:08 -0500
Content-Disposition: inline
In-Reply-To: <1455767939-2700534-2-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 07:58:57PM -0800, Alexei Starovoitov wrote:
> . avoid walking the stack when there is no room left in the buffer
> . generalize get_perf_callchain() to be called from bpf helper

If it does two things it should be two patches.

> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  arch/x86/include/asm/stacktrace.h |  2 +-
>  arch/x86/kernel/cpu/perf_event.c  |  4 ++--
>  arch/x86/kernel/dumpstack.c       |  6 ++++--
>  arch/x86/kernel/stacktrace.c      | 18 +++++++++++-------
>  arch/x86/oprofile/backtrace.c     |  3 ++-
>  include/linux/perf_event.h        | 13 +++++++++++--
>  kernel/events/callchain.c         | 32 ++++++++++++++++++++------------
>  kernel/events/internal.h          |  2 --
>  8 files changed, 51 insertions(+), 29 deletions(-)

And at the very least this should have had a note that it doesn't break
all the other archs that implement perf-callchain stuff.
