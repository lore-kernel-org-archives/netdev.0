From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 8/8] can: replace timestamp as unique skb attribute
Date: Tue, 4 Aug 2015 12:18:48 -0700
Message-ID: <20150804191848.GA29709@kroah.com>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
 <1436728691-1145-9-git-send-email-mkl@pengutronix.de>
 <55B679B8.30705@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, linux-stable <stable@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55B679B8.30705@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2015 at 08:34:32PM +0200, Oliver Hartkopp wrote:
> Hello Greg,
> 
> On 12.07.2015 21:18, Marc Kleine-Budde wrote:
> >From: Oliver Hartkopp <socketcan@hartkopp.net>
> >
> >Commit 514ac99c64b "can: fix multiple delivery of a single CAN frame for
> >overlapping CAN filters" requires the skb->tstamp to be set to check for
> >identical CAN skbs.
> >
> >Without timestamping to be required by user space applications this timestamp
> >was not generated which lead to commit 36c01245eb8 "can: fix loss of CAN frames
> >in raw_rcv" - which forces the timestamp to be set in all CAN related skbuffs
> >by introducing several __net_timestamp() calls.
> >
> >This forces e.g. out of tree drivers which are not using alloc_can{,fd}_skb()
> >to add __net_timestamp() after skbuff creation to prevent the frame loss fixed
> >in mainline Linux.
> >
> >This patch removes the timestamp dependency and uses an atomic counter to
> >create an unique identifier together with the skbuff pointer.
> >
> >Btw: the new skbcnt element introduced in struct can_skb_priv has to be
> >initialized with zero in out-of-tree drivers which are not using
> >alloc_can{,fd}_skb() too.
> >
> >Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> >Cc: linux-stable <stable@vger.kernel.org>
> 
> Can you please queue up this missing/lost patch for the long term 4.1.x ?
> 
> It fixes the mess with commits
> 
> 514ac99c64b "can: fix multiple delivery of a single CAN frame for
> overlapping CAN filters"
> 
> which originally fixed
> 
> 36c01245eb8 "can: fix loss of CAN frames in raw_rcv"
> 
> So finally this missing patch would bring 4.1.x into the proper state we now
> have in 4.2-rc4.
> 
> Upstream commit of this patch is:
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=d3b58c47d330de8c29898fe9746f7530408f8a59

It's in my queue, I still have way over 200 commits to get through for
4.1.x, your patches are in good company.

greg k-h
