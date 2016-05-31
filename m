From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fou: fix IPv6 Kconfig options
Date: Tue, 31 May 2016 14:08:04 -0700 (PDT)
Message-ID: <20160531.140804.27676513823707793.davem@davemloft.net>
References: <1464727353-22489-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, valentinrothberg@gmail.com, ziegler@cs.fau.de,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464727353-22489-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 31 May 2016 22:42:11 +0200

> The Kconfig options I added to work around broken compilation ended
> up screwing up things more, as I used the wrong symbol to control
> compilation of the file, resulting in IPv6 fou support to never be built
> into the kernel.
> 
> Changing CONFIG_NET_FOU_IPV6_TUNNELS to CONFIG_IPV6_FOU fixes that
> problem, I had renamed the symbol in one location but not the other,
> and as the file is never being used by other kernel code, this did not
> lead to a build failure that I would have caught.
> 
> After that fix, another issue with the same patch becomes obvious, as we
> 'select INET6_TUNNEL', which is related to IPV6_TUNNEL, but not the same,
> and this can still cause the original build failure when IPV6_TUNNEL is
> not built-in but IPV6_FOU is. The fix is equally trivial, we just need
> to select the right symbol.
> 
> I have successfully build 350 randconfig kernels with this patch
> and verified that the driver is now being built.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Reported-by: Valentin Rothberg <valentinrothberg@gmail.com>
> Fixes: fabb13db448e ("fou: add Kconfig options for IPv6 support")

Applied, thanks Arnd.
