From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next 2/4] perf tools: Introduce bpf-output event
Date: Wed, 28 Oct 2015 16:13:12 +0300
Message-ID: <5630C9E8.5090806@cogentembedded.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
 <1446029705-199659-3-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lizefan@huawei.com, pi3orama@163.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Wang Nan <wangnan0@huawei.com>, acme@kernel.org, ast@kernel.org,
	brendan.d.gregg@gmail.com, jolsa@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446029705-199659-3-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/28/2015 1:55 PM, Wang Nan wrote:

> Commit a43eec304259a6c637f4014a6d4767159b6a3aa3 (bpf: introduce
> bpf_perf_event_output() helper) add a helper to enable BPF program

    You haven't run the patch thru scripts/checkpath.pl, I guess? It now 
enforces the certain style of citing a commit.

> output data to perf ring buffer through a new type of perf event
> PERF_COUNT_SW_BPF_OUTPUT. This patch enable perf to create perf
> event of that type. Now perf user can use following cmdline to
> receive output data from BPF programs:
>
>   # perf record -a -e evt=bpf-output/no-inherit/ \
>                    -e ./test_bpf_output.c/maps.bpf-output.event=evt/ ls
>
>   # perf script
> 	perf 12927 [004] 355971.129276:          0 evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write
> 	perf 12927 [004] 355971.129279:          0 evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write
> 	...
>
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>   tools/perf/util/evsel.c        | 6 ++++++
>   tools/perf/util/parse-events.c | 4 ++++
>   tools/perf/util/parse-events.l | 1 +
>   3 files changed, 11 insertions(+)
>
> diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
> index 397fb4e..f01defb 100644
> --- a/tools/perf/util/evsel.c
> +++ b/tools/perf/util/evsel.c
> @@ -224,6 +224,12 @@ struct perf_evsel *perf_evsel__new_idx(struct perf_event_attr *attr, int idx)
>   	if (evsel != NULL)
>   		perf_evsel__init(evsel, attr, idx);
>
> +	if ((evsel->attr.type == PERF_TYPE_SOFTWARE) &&
> +	    (evsel->attr.config == PERF_COUNT_SW_BPF_OUTPUT)) {

    Inner parens not necessary here.

[...]

MBR, Sergei
