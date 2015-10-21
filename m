From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Wed, 21 Oct 2015 14:06:36 +0200
Message-ID: <20151021120636.GB3604@twins.programming.kicks-ass.net>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445396556-4854-3-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 20, 2015 at 08:02:34PM -0700, Alexei Starovoitov wrote:
> This helper is used to send raw data from eBPF program into
> special PERF_TYPE_SOFTWARE/PERF_COUNT_SW_BPF_OUTPUT perf_event.
> User space needs to perf_event_open() it (either for one or all cpus) and
> store FD into perf_event_array (similar to bpf_perf_event_read() helper)
> before eBPF program can send data into it.
> 

> diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
> index 2881145cda86..d3c417615361 100644
> --- a/include/uapi/linux/perf_event.h
> +++ b/include/uapi/linux/perf_event.h
> @@ -110,6 +110,7 @@ enum perf_sw_ids {
>  	PERF_COUNT_SW_ALIGNMENT_FAULTS		= 7,
>  	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
>  	PERF_COUNT_SW_DUMMY			= 9,
> +	PERF_COUNT_SW_BPF_OUTPUT		= 10,
>  
>  	PERF_COUNT_SW_MAX,			/* non-ABI */
>  };

Do you really need the new type? Can't you use DUMMY for this?
