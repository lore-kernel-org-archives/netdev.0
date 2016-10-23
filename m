From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp, forbid negative length
Date: Sun, 23 Oct 2016 17:44:05 -0400 (EDT)
Message-ID: <20161023.174405.1335530959467229046.davem@davemloft.net>
References: <20161021121324.13942-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, linux-kernel@vger.kernel.org,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021121324.13942-1-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 21 Oct 2016 14:13:24 +0200

> Most of getsockopt handlers in net/sctp/socket.c check len against
> sizeof some structure like:
>         if (len < sizeof(int))
>                 return -EINVAL;
> 
> On the first look, the check seems to be correct. But since len is int
> and sizeof returns size_t, int gets promoted to unsigned size_t too. So
> the test returns false for negative lengths. Yes, (-1 < sizeof(long)) is
> false.
> 
> Fix this in sctp by explicitly checking len < 0 before any getsockopt
> handler is called.
> 
> Note that sctp_getsockopt_events already handled the negative case.
> Since we added the < 0 check elsewhere, this one can be removed.
> 
> If not checked, this is the result:
...
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied and queued up for -stable, thanks.
