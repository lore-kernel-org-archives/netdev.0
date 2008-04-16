From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: X or AF_UNIX and order 3 allocation
Date: Wed, 16 Apr 2008 09:59:38 -0700
Message-ID: <20080416095938.66d798e4.zaitcev@redhat.com>
References: <20080415211055.882e67fe.zaitcev@redhat.com>
	<20080415.215144.87148045.davem@davemloft.net>
	<20080416085213.1e55bd1e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zaitcev@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932483AbYDPQ76@vger.kernel.org>
In-Reply-To: <20080416085213.1e55bd1e@extreme>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Apr 2008 08:52:13 -0700, Stephen Hemminger <shemminger@vyatta.com> wrote:

> > > Not sure if the problem is caused by X or kernel, but this is what
> > 
> > It seems to be the b44 driver doing a large huge order allocation.
> > 
> > That driver only asks for (1536 + 30 + 64) bytes, so I suppose part of
> > the problem is that SLAB is using an order 3 allocation to satisfy
> > that.

> The chip needs memory below 1G for DMA, perhaps low memory is getting
> exhausted.

The failure corresponds to memory pressure (from yum), but the real issue
is the lack of order 3 areas. We're talking a 32KB chunk! Why would anyone
need that much? Crazy!

Apr 13 18:19:14 niphredil kernel: Xorg: page allocation failure. order:3, mode:0x4020

I blame SLUB. Things like the above never happened with SLAB.

-- Pete
