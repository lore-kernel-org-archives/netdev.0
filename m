From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] bridge/netfilter: avoid unused label warning
Date: Thu, 08 Oct 2015 14:30:58 +0200
Message-ID: <6250097.aDMuaVNloH@wuerfel>
References: <7985748.1v9Gzszd4T@wuerfel> <20151008.044253.925506191056148131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org, fw@strlen.de, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151008.044253.925506191056148131.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 October 2015 04:42:53 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Tue, 06 Oct 2015 21:22:12 +0200
> 
> > With the ARM mini2440_defconfig, the bridge netfilter code gets
> > built with both CONFIG_NF_DEFRAG_IPV4 and CONFIG_NF_DEFRAG_IPV6
> > disabled, which leads to a harmless gcc warning:
> > 
> > net/bridge/br_netfilter_hooks.c: In function 'br_nf_dev_queue_xmit':
> > net/bridge/br_netfilter_hooks.c:792:2: warning: label 'drop' defined but not used [-Wunused-label]
> > 
> > This gets rid of the warning by cleaning up the code to avoid
> > the respective #ifdefs causing this problem, and replacing them
> > with if(IS_ENABLED()) checks. I have verified that the resulting
> > object code is unchanged, and an additional advantage is that
> > we now get compile coverage of the unused functions in more
> > configurations.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: dd302b59bde0 ("netfilter: bridge: don't leak skb in error paths")
> 
> This commit is in v4.2-rc3 and later, but this patch only applies to net-next
> as far as I can tell.
> 
> Wouldn't it be better to base this on 'net', or even better Pablo's netfilter
> fixes tree, and while you are at it submit it properly to netfilter-devel
> with Pablo CC:'d as well?

Ok, done.

	Arnd
