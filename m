From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [PATCH] mlx5: avoid unused variable warning
Date: Wed, 18 May 2016 18:11:27 +0300
Message-ID: <20160518151127.GA14887@office.localdomain>
References: <1463581293-1069553-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463581293-1069553-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 04:21:07PM +0200, Arnd Bergmann wrote:
> When CONFIG_NET_CLS_ACT is disabled, we get a new warning in the mlx5
> ethernet driver because the tc_for_each_action() loop never references
> the iterator:
> 
> mellanox/mlx5/core/en_tc.c: In function 'mlx5e_stats_flower':
> mellanox/mlx5/core/en_tc.c:431:20: error: unused variable 'a' [-Werror=unused-variable]
>   struct tc_action *a;
> 
> This changes the dummy tc_for_each_action() macro by adding a
> cast to void, letting the compiler know that the variable is
> intentionally declared but not used here. I could not come up
> with a nicer workaround, but this seems to do the trick.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: aad7e08d39bd ("net/mlx5e: Hardware offloaded flower filter statistics support")
> Fixes: 00175aec941e ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
> ---
Acked-By: Amir Vadai <amir@vadai.me>

Thanks Arnd.
