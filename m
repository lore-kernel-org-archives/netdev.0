From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Tue, 12 Jan 2016 15:05:19 +0100
Message-ID: <20160112140519.GG6357@twins.programming.kicks-ass.net>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
 <20160111180913.GA25950@ast-mbp.thefacebook.com>
 <56949028.2070208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, acme@kernel.org,
	linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Yunlong Song <yunlong.song@huawei.com>
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56949028.2070208@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 12, 2016 at 01:33:28PM +0800, Wangnan (F) wrote:
> >How about another idea:
> >. update data_tail pointer when head is about to overwrite it

> Even in the very first try at 2013 in [1], reading from the ring
> buffer is avoided. I don't think Peter changes his mind now.

So I don't object to that this approach per-se, as per:

 lkml.kernel.org/r/20151023151205.GW11639@twins.programming.kicks-ass.net

The main concern is doing it so that the regular !overwrite mode doesn't
suffer in performance.

The patch above choses to sacrifice about half the buffer space to avoid
having to fwd parse events on every overwrite, but doing the fwd search
is certainly possible (just really expensive).

> >Another concern is validity of records stored. If user space messes
> >with ring-buffer, kernel won't be able to move data_tail properly
> >and would need to indicate that to userspace somehow.
> >But memory saving of 8 bytes per record could be sizable
> 
> Yes. But I have already discussed with Peter on this in [2].

So given the trade-off between loosing half the buffer and adding 8
bytes to every event I'm not sure which is the worst.

Also, the way its implemented means they're not in fact mutually
exclusive, both can be had.
