From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 linux-next] net: fix rcu access on phonet_routes
Date: Mon, 06 Oct 2014 11:23:42 -0700
Message-ID: <1412619822.11091.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412619321-2212-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Remi Denis-Courmont <courmisch@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412619321-2212-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-10-06 at 20:15 +0200, Fabian Frederick wrote:
> -Add __rcu annotation on table to fix sparse warnings:
> net/phonet/pn_dev.c:279:25: warning: incorrect type in assignment (different address spaces)
> net/phonet/pn_dev.c:279:25:    expected struct net_device *<noident>
> net/phonet/pn_dev.c:279:25:    got void [noderef] <asn:4>*<noident>
> net/phonet/pn_dev.c:376:17: warning: incorrect type in assignment (different address spaces)
> net/phonet/pn_dev.c:376:17:    expected struct net_device *volatile <noident>
> net/phonet/pn_dev.c:376:17:    got struct net_device [noderef] <asn:4>*<noident>
> net/phonet/pn_dev.c:392:17: warning: incorrect type in assignment (different address spaces)
> net/phonet/pn_dev.c:392:17:    expected struct net_device *<noident>
> net/phonet/pn_dev.c:392:17:    got void [noderef] <asn:4>*<noident>
> 
> -Access table with rcu_access_pointer (fixes the following sparse errors):
> net/phonet/pn_dev.c:278:25: error: incompatible types in comparison expression (different address spaces)
> net/phonet/pn_dev.c:391:17: error: incompatible types in comparison expression (different address spaces)
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> V2: use rcu_access_pointer instead of rcu_dereference out of rcu_read_lock context
>     (suggested by Eric Dumazet).

Acked-by: Eric Dumazet <edumazet@google.com>
