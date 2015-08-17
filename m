From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: limit tcp/udp rmem/wmem to
 SOCK_{RCV,SND}BUF_MIN"
Date: Mon, 17 Aug 2015 12:11:14 -0700 (PDT)
Message-ID: <20150817.121114.1040758760525721568.davem@davemloft.net>
References: <20150810.204630.1903301700926701432.davem@davemloft.net>
	<20150812045420.GA3908557@mail.thefacebook.com>
	<20150813212134.GA3070917@mail.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, sorin@returnze.ro
To: calvinowens@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150813212134.GA3070917@mail.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Calvin Owens <calvinowens@fb.com>
Date: Thu, 13 Aug 2015 14:21:34 -0700

> Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
> SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
> written to them are not less than SOCK_MIN_{RCV,SND}BUF.
> 
> That change causes 4096 to no longer be accepted as a valid value for
> 'min' in tcp_wmem and udp_wmem_min. 4096 has been the default for both
> of those sysctls for a long time, and unfortunately seems to be an
> extremely popular setting. This change breaks a large number of sysctl
> configurations at Facebook.
> 
> That commit referred to b1cb59cf2efe7971 ("net: sysctl_net_core: check
> SNDBUF and RCVBUF for min length"), which choose to use the SOCK_MIN
> constants as the lower limits to avoid nasty bugs. But AFAICS, a limit
> of SOCK_MIN_SNDBUF isn't necessary to do that: the BUG_ON cited in the
> commit message seems to have happened because unix_stream_sendmsg()
> expects a minimum of a full page (ie SK_MEM_QUANTUM) and the math broke,
> not because it had less than SOCK_MIN_SNDBUF allocated.
> 
> This particular issue doesn't seem to affect TCP however: using a
> setting of "1 1 1" for tcp_{r,w}mem works, although it's obviously
> suboptimal. SK_MEM_QUANTUM would be a nice minimum, but it's 64K on
> some archs, so there would still be breakage.
> 
> Since a value of one doesn't seem to cause any problems, we can drop the
> minimum 8133534c added to fix this.
> 
> This reverts commit 8133534c760d4083f79d2cde42c636ccc0b2792e.
> 
> Fixes: 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to SOCK_MIN...")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Sorin Dumitru <sorin@returnze.ro>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>

Applied, thanks.
