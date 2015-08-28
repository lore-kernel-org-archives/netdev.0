From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 net-next 1/2] lib: introduce strncpy_from_unsafe()
Date: Fri, 28 Aug 2015 18:11:41 -0400
Message-ID: <20150828181141.6d974130@gandalf.local.home>
References: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
	<1440791509-5450-2-git-send-email-ast@plumgrid.com>
	<20150828174813.23e6e78b@gandalf.local.home>
	<55E0DBE3.8010504@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E0DBE3.8010504@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Aug 2015 15:08:35 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> On 8/28/15 2:48 PM, Steven Rostedt wrote:
> >>   * On success, returns the length of the string (not including the trailing
> >> >+ * NUL).
> > I think it includes the NUL.
> 
> oops. yes. that was a copy paste from strncpy_from_user comment.
> trace_kprobe usage wants NUL to be counted, so I intended to have it
> counted, but that brings the question what should be the semantics.
> Should it be similar to strncpy_from_user (not counting NUL) or
> similar to strlen_user (counts NUL) ?
> imo counting NUL makes a little bit more sense, since when a user says
> strncpy_from_unsafe(..., ..., 32)
> and it returns 32 as the whole buffer was filled, it looks cleaner.
> Thoughts?
> 

I personally prefer counting the NUL. I've had issues in the past with
the strncpy_from_user() not counting it :-p

-- Steve
