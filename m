From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB
 devices
Date: Mon, 01 Jul 2013 11:03:59 -0700
Message-ID: <1372701839.2481.3.camel@joe-AO722>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	 <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38965 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753587Ab3GASEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 14:04:00 -0400
In-Reply-To: <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-01 at 10:49 -0700, Roland Dreier wrote:
> So I'm inclined to apply the mlx5 driver for 3.11, since it's a
> completely new driver.  However, reading through it so far I had the
> following comments, and I'd like these cleanups addressed along with
> Dave Miller's:
> 
> - The debug mask complexity seems unnecessary now that pr_debug() is
> controllable at runtime with the DYNAMIC_DEBUG stuff.  We should get
> rid of the extra level of indirection.

There's some value in block enabling/disabling messages
that dynamic_debug doesn't currently offer.

> - In:
> 
> +struct mlx5_cmd {
> ...
> +    struct mlx5_cmd_stats    stats[0x80a];
> 
> the 0x80a magic number really needs to have a name.

And that's a pretty big struct too.
2058 array entries. ~100kb
Does it really need to be that big?
