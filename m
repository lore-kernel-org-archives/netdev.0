From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Wed, 1 Dec 2010 12:18:01 -0500
Message-ID: <20101201171801.GA22009@canuck.infradead.org>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
 <1291219386.2856.924.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291219386.2856.924.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 01, 2010 at 05:03:06PM +0100, Eric Dumazet wrote:
> [PATCH net-next-2.6] net: kill an RCU warning in inet_fill_link_af()
> 
> commits 9f0f7272 (ipv4: AF_INET link address family) and cf7afbfeb8c
> (rtnl: make link af-specific updates atomic) used incorrect
> __in_dev_get_rcu() in RTNL protected contexts, triggering PROVE_RCU
> warnings.
> 
> Switch to __in_dev_get_rtnl(), wich is more appropriate, since we hold
> RTNL.
> 
> Based on a report and initial patch from Amerigo Wang.

RTNL is not held while dumping, it is only held for get and set, but we
still hold rcu readlocks while dumping so there should be no asserts
triggered. Thanks for fixing this.
