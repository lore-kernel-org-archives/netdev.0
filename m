From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Unbreak resetting default values for
 tcp_wmem/udp_wmem_min
Date: Sun, 09 Aug 2015 22:41:14 -0700 (PDT)
Message-ID: <20150809.224114.818332231954008575.davem@davemloft.net>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, sorin@returnze.ro
To: calvinowens@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Calvin Owens <calvinowens@fb.com>
Date: Wed, 5 Aug 2015 13:26:54 -0700

> Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
> SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
> written to them are not less than SOCK_MIN_{RCV,SND}BUF.
> 
> This change is fine for tcp_rmem and udp_rmem_min, since SOCK_MIN_RCVBUF
> is equal to equal to TCP_SKB_MIN_TRUESIZE. But it breaks tcp_wmem and
> udp_wmem_min for previously valid values because SOCK_MIN_SNDBUF is
> (2 * TCP_SKB_MIN_TRUESIZE), which ends up being greater than 4KB.
> 
> Thus, 4096 is no longer accepted as a valid value, despite still being
> the default for udp_wmem_min, and for 'min' in tcp_wmem. A huge number
> of sysctl configurations at FB use 4096 as 'min', so this change breaks
> all of them.
> 
> This patch changes the sysctls to simply enforce that the value written
> is greater than or equal to the default value of SK_MEM_QUANTUM.
> 
> Fixes: 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to SOCK_MIN...")
> Signed-off-by: Calvin Owens <calvinowens@fb.com>

I think increasing the default makes more sense.

If we don't allow applications to set 4K, the kernel shouldn't start
with that value either.
