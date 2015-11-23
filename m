From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: avoid harmless unnitialized variable warnings
Date: Mon, 23 Nov 2015 11:23:02 +0100
Message-ID: <20151123102302.GA1614@salvia>
References: <5585663.OcpAQiytKY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5585663.OcpAQiytKY@wuerfel>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 19, 2015 at 01:49:59PM +0100, Arnd Bergmann wrote:
> Several ARM default configurations give us warnings on recent
> compilers about potentially uninitialized variables in the
> nfnetlink code in two functions:
> 
> net/netfilter/nfnetlink_queue.c: In function 'nfqnl_build_packet_message':
> net/netfilter/nfnetlink_queue.c:519:19: warning: 'nfnl_ct' may be used uninitialized in this function [-Wmaybe-uninitialized]
>   if (ct && nfnl_ct->build(skb, ct, ctinfo, NFQA_CT, NFQA_CT_INFO) < 0)
> 
> Moving the rcu_dereference(nfnl_ct_hook) call outside of the
> conditional code avoids the warning without forcing us to
> preinitialize the variable.

Applied, thanks Arnd.

