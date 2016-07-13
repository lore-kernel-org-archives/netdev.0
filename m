From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/3] perf, events: add non-linear data support
 for raw records
Date: Wed, 13 Jul 2016 09:52:09 +0200
Message-ID: <20160713075209.GQ30154@twins.programming.kicks-ass.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
 <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2016 at 12:36:17AM +0200, Daniel Borkmann wrote:
> This patch adds support for non-linear data on raw records. It means
> that for such data, the newly introduced __output_custom() helper will
> be used instead of __output_copy(). __output_custom() will invoke
> whatever custom callback is passed in via struct perf_raw_record_frag
> to extract the data into the ring buffer slot.
> 
> To keep changes in perf_prepare_sample() and in perf_output_sample()
> minimal, size/size_head split was added to perf_raw_record that call
> sites fill out, so that two extra tests in fast-path can be avoided.
> 
> The few users of raw records are adapted to initialize their size_head
> and frag data; no change in behavior for them. Later patch will extend
> BPF side with a first user and callback for this facility, future users
> could be things like XDP BPF programs (that work on different context
> though and would thus have a different callback), etc.

Why? What problem are we solving?
