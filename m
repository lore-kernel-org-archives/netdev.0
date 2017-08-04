From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Fri, 04 Aug 2017 10:43:12 -0700
Message-ID: <1501868592.25002.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170804043328.4730-1-f.fainelli@gmail.com>
         <1501824968.25002.35.camel@edumazet-glaptop3.roam.corp.google.com>
         <455c39d3-302e-68ab-3812-112c48ed48c2@gmail.com>
         <1501866711.25002.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemlot.net,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501866711.25002.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-08-04 at 10:11 -0700, Eric Dumazet wrote:

> You could add a debug version of u64_stats_update_begin()
> 
> doing 
> 
> int ret = atomic_inc((atomic_t *)syncp);

I meant atomic_inc_return() of course.

> 
> BUG_ON(ret & 1);
> 
> 
> And u64_stats_update_end()
> 
> int ret = atomic_inc((atomic_t *)syncp);
> 
> BUG_ON(!(ret & 1));
> 
> 
> We probably could have a CONFIG_DEBUG_U64_STATS  that could be used on
> 64bit kernels as well...
> 
> 
> 
