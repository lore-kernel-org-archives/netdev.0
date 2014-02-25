From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Tue, 25 Feb 2014 23:55:10 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1402252350210.5180@pobox.suse.cz>
References: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz> <CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com> <alpine.LNX.2.00.1402252307130.5180@pobox.suse.cz> <CAJZOPZJpRYKw7Dskr21QP_d6c7ySS+mi-g_19pNJYm0Gq=ZY+g@mail.gmail.com>
 <alpine.LNX.2.00.1402252338480.5180@pobox.suse.cz> <CAJZOPZ+C55GriKwhQ7Efa6cqDavZQP6FxfbJx4xmuCi-VZp-OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZ+C55GriKwhQ7Efa6cqDavZQP6FxfbJx4xmuCi-VZp-OQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Feb 2014, Or Gerlitz wrote:

> Still, even if different, I still don't see why not use datagram mode
> if the problem hits you only for connected mode. E.g datagram mode
> supports LSO/GRO and TX/RX checksum offloads which should cover on the
> smaller MTU vs. connected mode
[ ... snip ... ]
> > Yes, but for datagram mode, the tx_ring is allocated in a completely
> > different way (not from kworker), so this might be a non-issue, right? I
> > will have to look into it more deeply to be really sure; if you can
> > provide your insight, that'd be helpful.
> 
> Note that even when operating in connected mode, the ipoib net-device
> instance can speak in datagram mode with remote nodes who don't
> support connected mor and/or when sending multicast -- specifically
> ipoib_dev_init() does the setup of the TX ring. Maybe you can just try
> this out and see if it works?

That definitely can be verified, and I am putting it on my TODO list.

But let's make sure that we don't diverge from the original problem too 
much. Simple fact is that the deadlock is there when using connected mode, 
and there is nothing preventing users from using it this way, therefore I 
believe it should be fixed one way or another.

If the problem is still there in datagram mode (which, as far as my 
understanding of the code goes, is not the case), it should be fixed as 
well, but that's a different story.

Thanks,

-- 
Jiri Kosina
SUSE Labs
