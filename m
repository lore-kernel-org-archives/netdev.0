From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge/netfilter: avoid unused label warning
Date: Thu, 08 Oct 2015 04:42:53 -0700 (PDT)
Message-ID: <20151008.044253.925506191056148131.davem@davemloft.net>
References: <7985748.1v9Gzszd4T@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, pablo@netfilter.org,
	ebiederm@xmission.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7985748.1v9Gzszd4T@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 06 Oct 2015 21:22:12 +0200

> With the ARM mini2440_defconfig, the bridge netfilter code gets
> built with both CONFIG_NF_DEFRAG_IPV4 and CONFIG_NF_DEFRAG_IPV6
> disabled, which leads to a harmless gcc warning:
> 
> net/bridge/br_netfilter_hooks.c: In function 'br_nf_dev_queue_xmit':
> net/bridge/br_netfilter_hooks.c:792:2: warning: label 'drop' defined but not used [-Wunused-label]
> 
> This gets rid of the warning by cleaning up the code to avoid
> the respective #ifdefs causing this problem, and replacing them
> with if(IS_ENABLED()) checks. I have verified that the resulting
> object code is unchanged, and an additional advantage is that
> we now get compile coverage of the unused functions in more
> configurations.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: dd302b59bde0 ("netfilter: bridge: don't leak skb in error paths")

This commit is in v4.2-rc3 and later, but this patch only applies to net-next
as far as I can tell.

Wouldn't it be better to base this on 'net', or even better Pablo's netfilter
fixes tree, and while you are at it submit it properly to netfilter-devel
with Pablo CC:'d as well?

Thanks.
