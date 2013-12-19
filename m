From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] ixgbe: acquire RCU read lock when calling netdev_for_each_all_upper_dev_rcu()
Date: Wed, 18 Dec 2013 22:38:13 -0800
Message-ID: <52B29455.6010109@intel.com>
References: <1387432860-14021-1-git-send-email-jiang.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiang Liu <jiang.liu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387432860-14021-1-git-send-email-jiang.liu@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/18/2013 10:00 PM, Jiang Liu wrote:
> According to documentation for netdev_for_each_all_upper_dev_rcu(),
> caller should take RCU read lock, otherwise it will trigger following
> warnings. The simplest fix is to protect with rcu_read_lock()/
> rcu_read_unlock(). And this solutions passes basic tests.
>
> Otherwise we may need to introduce  netdev_for_each_all_upper_dev()
> as netdev_lower_get_next_private(), which assumes the caller has
> gained the lock to protect the list.
>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---

Jiang,

The following patch addresses the same issue,

http://patchwork.ozlabs.org/patch/302711/
  [net,1/5] net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock held

It is under review and solves the problem by having the call check for
the rtnl lock as well. Take a look. I think it is a slightly better fix
in that it doesn't clutter the driver with unnecessary rcu_read_lock()
and rcu_read_unlock() calls.

Thanks,
John
