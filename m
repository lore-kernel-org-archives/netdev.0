From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 14:47:03 +0800
Message-ID: <1337755623.14538.194.camel@ymzhang.sh.intel.com>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
	 <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337747829.3361.1599.camel@edumazet-glaptop>
	 <1337748897.14538.184.camel@ymzhang.sh.intel.com>
	 <1337749339.3361.1655.camel@edumazet-glaptop>
	 <1337753757.14538.190.camel@ymzhang.sh.intel.com>
	 <1337754459.3361.1850.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337754459.3361.1850.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-23 at 08:27 +0200, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 14:15 +0800, Yanmin Zhang wrote:
> 
> > 
> > Besides fi->fib_dev here, we need check fi->fib_hash, fi->fib_lhash,
> > and nexthop_nh->nh_hash.
> 
> No, its not needed.
I am checking it now.
fib_create_info=>fib_find_info, but fib_find_info is not protected by
fib_info_lock. See the codes:


link_it:
        ofi = fib_find_info(fi);
        if (ofi) {
                fi->fib_dead = 1;
                free_fib_info(fi);
                ofi->fib_treeref++;
                return ofi;
        }

> 
> I am sending a patch, because I feel this area is too complex for non
> netdev guys.
Indeed, it's complicated. I will test your patches.
