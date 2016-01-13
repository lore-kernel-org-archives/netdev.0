From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] bpf: bpf_htab: Add syscall to iterate
 percpu value of a key
Date: Tue, 12 Jan 2016 18:24:56 -0800
Message-ID: <1452651896.1223.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
	 <1452586852-1575604-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Ming Lei <tom.leiming@gmail.com>,
	FB Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452586852-1575604-4-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 00:20 -0800, Martin KaFai Lau wrote:
> Add map_lookup_percpu_elem() syscall to lookup value
> of a particular CPU.

...

> +static int map_lookup_percpu_elem(union bpf_attr *attr)
> +{
> +	void __user *ukey = u64_to_ptr(attr->key);
> +	void __user *uvalue = u64_to_ptr(attr->value);
> +	u32 __user ucpu = attr->cpu;
> +	int ufd = attr->map_fd;
> +	struct percpu_map_value_info value_info;
> +	struct bpf_map *map;
> +	void *key, *value;
> +	struct fd f;
> +	int err;
> +
> +	if (CHECK_ATTR(BPF_MAP_LOOKUP_PERCPU_ELEM) ||
> +	    ucpu >= num_possible_cpus())
> +		return -EINVAL;

Arg, a num_possible_cpus() wrong call.

You probably want to use    (ucpu >= nr_cpu_ids)

hint : You can have hosts with 2 possibles cpus, CPU0 and CPU2

So the userland loop in your changelog is wrong.
