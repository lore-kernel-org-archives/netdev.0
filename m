From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 7 Jan 2010 18:56:10 +0100
Message-ID: <20100107175610.GA3088@del.dom.local>
References: <4B454A16.3030909@majjas.com>
 <4B455C62.6030504@majjas.com>
 <20100106205343.5460d658@nehalam>
 <4B4571D5.30002@majjas.com>
 <4B457711.1040008@majjas.com>
 <4B458B36.6050509@majjas.com>
 <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com>
 <20100107082140.GB7229@ff.dom.local>
 <4B45F7D7.3060308@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752584Ab0AGR4V@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B45F7D7.3060308@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2010 at 10:03:51AM -0500, Michael Breuer wrote:
> On 1/7/2010 3:21 AM, Jarek Poplawski wrote:
> >On Thu, Jan 07, 2010 at 02:55:20AM -0500, Michael Breuer wrote:
> >>Unless I misread the code, I think that in some cases e skb is actually
> >>freed if the cfq (among others perhaps) scheduler returns an error on
> >>enqueue (flow control perhaps).  Thus with alternative 1, it is possible
> >>that the skb is acted upon after being freed - this would be consistent
> >>with the DMAR errors I saw.
> >I can't see your point: could you give some scenario?
> >
> >Jarek P.
> With NET_CLS_ACT set, net_dev_enqueue can return an error after
> freeing the skb. Alternative 1 disregards the error and assumes the
> skb is still valid. The original code and alternative 2 exit the
> loop assuming the skb has been freed.

Not exactly: alternative 1 disregards the error, and tries to send
next skbs if the message was longer. After consuming all the message
it returns without err code (at least wrt. dev_queue_xmit). This is
quite often practice to skip dev_queue_xmit() return (try to grep in
net\). It should never touch any part of an earlier sent skb.

Jarek P.
