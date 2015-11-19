From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Date: Thu, 19 Nov 2015 14:50:24 +0100
Message-ID: <20151119135023.GH8494@dhcp22.suse.cz>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
 <20151118162256.GK19145@dhcp22.suse.cz>
 <20151118214822.GA1365@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151118214822.GA1365@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 18-11-15 16:48:22, Johannes Weiner wrote:
[...]
> So I ran perf record -g -a netperf -t TCP_STREAM multiple times inside
> a memory-controlled cgroup, but mostly mem_cgroup_charge_skmem() does
> not show up in the profile at all. Once it was there with 0.00%.

OK, this sounds very good! This means that most workloads which are not
focusing solely on the network traffic shouldn't even notice. I can
imagine that workloads with high throughput demands would notice but I
would also expect them to disable the feature.

Could you add this information to the changelog, please?

> I ran another test that downloads the latest kernel image from
> kernel.org at 13MB/s (on my i5 laptop) and it looks like this:
> 
>      0.02%     0.01%  irq/44-iwlwifi   [kernel.kallsyms]           [k] mem_cgroup_charge_skmem
>              |
>              ---mem_cgroup_charge_skmem
>                 __sk_mem_schedule
>                 tcp_try_rmem_schedule
>                 tcp_data_queue
>                 tcp_rcv_established
>                 tcp_v4_do_rcv
>                 tcp_v4_rcv
>                 ip_local_deliver
>                 ip_rcv
>                 __netif_receive_skb_core
>                 __netif_receive_skb
>                 netif_receive_skb_internal
>                 napi_gro_complete
> 
> The runs vary too much for this to be measurable in elapsed time.

-- 
Michal Hocko
SUSE Labs
