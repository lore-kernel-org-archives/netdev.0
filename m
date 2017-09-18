From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nat: Do not use ARRAY_SIZE() on spinlocks to
 fix zero div
Date: Mon, 18 Sep 2017 17:33:47 +0200
Message-ID: <20170918153347.GA28198@salvia>
References: <1505043701-13255-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1505043701-13255-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 10, 2017 at 01:41:41PM +0200, Geert Uytterhoeven wrote:
> If no spinlock debugging options (CONFIG_GENERIC_LOCKBREAK,
> CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_LOCK_ALLOC) are enabled on a UP
> platform (e.g. m68k defconfig), arch_spinlock_t is an empty struct,
> hence using ARRAY_SIZE(nf_nat_locks) causes a division by zero:
> 
>     net/netfilter/nf_nat_core.c: In function ‘nf_nat_setup_info’:
>     net/netfilter/nf_nat_core.c:432: warning: division by zero
>     net/netfilter/nf_nat_core.c: In function ‘__nf_nat_cleanup_conntrack’:
>     net/netfilter/nf_nat_core.c:535: warning: division by zero
>     net/netfilter/nf_nat_core.c:537: warning: division by zero
>     net/netfilter/nf_nat_core.c: In function ‘nf_nat_init’:
>     net/netfilter/nf_nat_core.c:810: warning: division by zero
>     net/netfilter/nf_nat_core.c:811: warning: division by zero
>     net/netfilter/nf_nat_core.c:824: warning: division by zero
> 
> Fix this by using the CONNTRACK_LOCKS definition instead.

Applied.
