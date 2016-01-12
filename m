From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Tue, 12 Jan 2016 15:14:30 +0100
Message-ID: <20160112141430.GH6357@twins.programming.kicks-ass.net>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@kernel.org, linux-kernel@vger.kernel.org, pi3orama@163.com,
	lizefan@huawei.com, netdev@vger.kernel.org, davem@davemloft.net,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Yunlong Song <yunlong.song@huawei.com>
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 01:48:18PM +0000, Wang Nan wrote:
> Before reading such ring buffer, perf must ensure all events which may
> output to it is already stopped, so the 'head' pointer it get is the
> end of the last record.

We could add an extra ioctl() to pause/resume ring-buffer output to make
this more convenient to achieve.

Say replace the !rb->nr_pages test in perf_output_begin() with a control
variable load and ensure its set to pause/fail when !nr_pages.

That way we only have to issue a single ioctl to freeze the buffer,
without adding extra instructions/loads to the fast path.
