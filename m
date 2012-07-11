From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] etherdevice: introduce eth_broadcast_addr
Date: Tue, 10 Jul 2012 18:09:27 -0700
Message-ID: <1341968967.13724.23.camel@joe2Laptop>
References: <20120708.235808.1602900783296556684.davem@davemloft.net>
	 <1341937124.4475.27.camel@jlt3.sipsolutions.net>
	 <CAP=VYLqNyAF1gSsKTd3YojeJXK_-pEzXAKyVQbQfwhtwOyMmwg@mail.gmail.com>
	 <20120710.174142.995966539991957646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120710.174142.995966539991957646.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 17:41 -0700, David Miller wrote:
> From: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
> Date: Tue, 10 Jul 2012 20:09:44 -0400
> 
> > On Tue, Jul 10, 2012 at 12:18 PM, Johannes Berg
> > <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> >> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >>
> >> A lot of code has either the memset or an inefficient copy
> >> from a static array that contains the all-ones broadcast
> > 
> > Shouldn't we see all that "lot of code" here in this same
> > commit, now using this new shortcut?

If I grepped properly, there are 42 instances of static arrays for
for broadcast ethernet addresses in drivers/net and drivers/staging
so it'd save some smallish amount of code by using a combination of
is_broadcast_ether_addr and this new func.

I think there are 53 instances of the memset(foo, 0xff, 6|ETH_ALEN).

> I disagree and I intend to apply Johannes's patch as-is to net-next.

Sounds fine to me.

For some additional style symmetry, how about a conversion of
random_ether_address to eth_random_addr too via

o Rename random_ether_addr to eth_random_addr and add a
  #define random_ether_addr eth_random_addr
o sed 's/\brandom_ether_addr\b/eth_random_addr/g' files_that_use_REA
o remove the #define after awhile


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
