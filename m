From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] perf/core: Put size of a sample at the end of
 it by PERF_SAMPLE_TAILSIZE
Date: Mon, 11 Jan 2016 18:05:10 +0100
Message-ID: <5693E0C6.2080509@iogearbox.net>
References: <1452518653-1794-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pi3orama@163.com, lizefan@huawei.com,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Yunlong Song <yunlong.song@huawei.com>
To: Wang Nan <wangnan0@huawei.com>, davem@davemloft.net,
	acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452518653-1794-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wang,

On 01/11/2016 02:24 PM, Wang Nan wrote:
> This patch introduces a PERF_SAMPLE_TAILSIZE flag which allows a size
> field attached at the end of a sample. The idea comes from [1] that,
> with tie size at tail of an event, it is possible for user program who
> read from the ring buffer parse events backward.
>
> For example:
>
>     head
>      |
>      V
>   +--+---+-------+----------+------+---+
>   |E6|...|   B  8|   C    11|  D  7|E..|
>   +--+---+-------+----------+------+---+
>
> In this case, from the 'head' pointer provided by kernel, user program
> can first see '6' by (*(head - sizeof(u64))), then it can get the start
> pointer of record 'E', then it can read size and find start position
> of record D, C, B in similar way.
>
> The implementation is easy: adding a PERF_SAMPLE_TAILSIZE flag, makes
> perf_output_sample() output size at the end of a sample.
>
> Following things are done for ensure the ring buffer is safe for
> backward parsing:
>
>   - Don't allow two events with different PERF_SAMPLE_TAILSIZE setting
>     set their output to each other;
>
>   - For non-sample events, also output tailsize if required.
>
> This patch has a limitation for perf:
>
> Before reading such ring buffer, perf must ensure all events which may
> output to it is already stopped, so the 'head' pointer it get is the
> end of the last record.
>
> [1] http://lkml.kernel.org/g/1449063499-236703-1-git-send-email-wangnan0@huawei.com
>
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Adrian Hunter <adrian.hunter@intel.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: David Ahern <dsahern@gmail.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Yunlong Song <yunlong.song@huawei.com>
> Cc: David S. Miller <davem@davemloft.net>
[...]

As this seems unrelated to networking, net-next tree seems not really appropriate?

Cheers,
Daniel
