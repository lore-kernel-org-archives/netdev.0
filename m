From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] bpf: convert hashtab lock to raw lock
Date: Mon, 2 Nov 2015 12:24:05 -0500
Message-ID: <20151102122405.56dd97a1@gandalf.local.home>
References: <1446243386-26582-1-git-send-email-yang.shi@linaro.org>
	<20151031000356.GA28070@Alexeis-MacBook-Pro.local>
	<20151031094736.494427d7@grimm.local.home>
	<56350A86.5090500@iogearbox.net>
	<5637997D.1020502@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	ast@kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org
To: "Shi, Yang" <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5637997D.1020502@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 02 Nov 2015 09:12:29 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:

> Yes, it is common practice for converting sleepable spin lock to raw 
> spin lock in -rt to avoid scheduling in atomic context bug.

Note, in a lot of cases we don't just convert spin_locks to raw because
of atomic context. There's times we need to change the design where the
lock is not taken in atomic context (switching preempt_disable() to a
local_lock() for example).

But bpf is much like ftrace and kprobes where they can be taken almost
anywhere, and the do indeed need to be raw.

-- Steve
