From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 2/4] bpf: Add new bpf map type to store the pointer to
 struct perf_event
Date: Wed, 5 Aug 2015 11:43:05 +0200
Message-ID: <20150805094305.GY25159@twins.programming.kicks-ass.net>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-3-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, davem@davemloft.net, acme@kernel.org,
	mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438678696-88289-3-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 04, 2015 at 08:58:14AM +0000, Kaixu Xia wrote:
> +static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
> +{
> +	struct perf_event *event;
> +	struct perf_event_attr *attr;
> +
> +	event = perf_event_get(fd);
> +	if (IS_ERR(event))
> +		return event;
> +
> +	attr = perf_event_attrs(event);
> +	if (IS_ERR(attr)) {
		perf_event_release_kernel(event);
> +		return attr;
	}

And maybe I should do a tree wide:
s/perf_event_release_kernel/perf_event_put/, but that's not too
important and can be done at any time.

> +
> +	if (attr->type != PERF_TYPE_RAW &&
> +	    attr->type != PERF_TYPE_HARDWARE) {
> +		perf_event_release_kernel(event);
> +		return ERR_PTR(-EINVAL);
> +	}
> +	return event;
> +}
