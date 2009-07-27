From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Mon, 27 Jul 2009 12:34:42 +0200
Message-ID: <b5ddba180907270334m4bc4e968m85c16ea4756c3f5d@mail.gmail.com>
References: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
	 <4A6D7285.9080909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-users@linuxvirtualserver.org,
	malcolm@loadbalancer.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756021AbZG0Ket@vger.kernel.org>
In-Reply-To: <4A6D7285.9080909@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 11:25, Eric Dumazet<eric.dumazet@gmail.com> wrote:
> Well, ip_vs_conn_cache uses SLAB_HWCACHE_ALIGN, so this should be rounded up
> to L1 cache size. Or add "at least" like in line 1080
> of net/netfilter/ipvs/ip_vs_conn.c :
>
> IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
>           sizeof(struct ip_vs_conn));

Good point.  Is there an easy way to figure out how much memory is
wasted for alignment by the slab allocator?  Otherwise I vote for the
"at least" approach.

-Hannes
