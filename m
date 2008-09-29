From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 10:45:18 +0400
Message-ID: <20080929064518.GA10653@2ka.mipt.ru>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:33930 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbYI2Gqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 02:46:45 -0400
Content-Disposition: inline
In-Reply-To: <20080929064006.GA23967@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 02:40:06PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Mon, Sep 29, 2008 at 09:52:03AM +0400, Evgeniy Polyakov wrote:
> > On Mon, Sep 29, 2008 at 01:40:52PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > Are you using Xen FV or PV? What processor?
> > 
> > Can I determine that within guest?
> 
> cat /proc/interrupts
> 
> should do the trick

That's what I have:

$ cat /proc/interrupts 
CPU0       
0:         71    XT-PIC-XT        timer
1:          8    XT-PIC-XT        i8042
2:          0    XT-PIC-XT        cascade
5:      17606    XT-PIC-XT        eth0
12:          5    XT-PIC-XT        i8042
14:       6925    XT-PIC-XT        ide0
15:        141    XT-PIC-XT        ide1
NMI:          0   Non-maskable interrupts
LOC:    1190668   Local timer interrupts
RES:          0   Rescheduling interrupts
CAL:          0   function call interrupts
TLB:          0   TLB shootdowns
TRM:          0   Thermal event interrupts
SPU:          0   Spurious interrupts
ERR:          0
MIS:          0


> > Actually it is a bit strange, if full or paravirtualization affects how
> > loopback network works, I thought it should only affect communication
> > between domains?
> 
> It also affects the MMU and other things.

Shouldn't tests over loopback be like lots of memcpy in the userspace
process? Usually its performance is close enough to the kernel's range,
despite very different sizes of TLB entries.

-- 
	Evgeniy Polyakov
