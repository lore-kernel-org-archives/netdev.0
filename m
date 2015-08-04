From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read() that
 get the selected hardware PMU conuter
Date: Tue, 4 Aug 2015 10:55:15 -0700
Message-ID: <55C0FC83.10504@plumgrid.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/15 1:58 AM, Kaixu Xia wrote:
> +static int check_func_limit(struct bpf_map **mapp, int func_id)

how about 'check_map_func_compatibility' or 'check_map_func_affinity' ?

> +{
> +	struct bpf_map *map = *mapp;

why pass pointer to a pointer? single pointer would be be fine.

> +	bool bool_map, bool_func;
> +	int i;
> +
> +	if (!map)
> +		return 0;
> +
> +	for (i = 0; i <= ARRAY_SIZE(func_limit); i++) {
> +		bool_map = (map->map_type == func_limit[i].map_type);
> +		bool_func = (func_id == func_limit[i].func_id);
> +		/* only when map & func pair match it can continue.
> +		 * don't allow any other map type to be passed into
> +		 * the special func;
> +		 */
> +		if (bool_map != bool_func)
> +			return -EINVAL;
> +	}

nice simplification!

the rest of the changes look good.
please respin your next set against net-next.
