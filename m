From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Wed, 10 Jan 2007 12:01:23 -0800
Message-ID: <20070110120123.52376578@freekitty>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>
	<E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
	<20070104.123333.91315611.davem@davemloft.net>
	<459EB627.5040606@candelatech.com>
	<20070108065346.GA1665@ff.dom.local>
	<45A277E6.6000904@candelatech.com>
	<20070108100350.1187a3dc@freekitty>
	<20070109081045.GA1703@ff.dom.local>
	<20070110090411.GA1589@ff.dom.local>
	<20070110125048.GB2611@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47514 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965056AbXAJUEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:04:52 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070110125048.GB2611@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Jan 2007 13:50:48 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On Wed, Jan 10, 2007 at 10:04:11AM +0100, Jarek Poplawski wrote:
> ...
> > It looks like you're talking about the right thing
> > and I'm a fool again! Now I try to find why I even 
> > had to pay for this. I read again and again adequate
> > chapters from R. Love and C. Benvenuti's books, see
> > a lot about kernel preemption in 2.6, but can't see
> > anything about preemption disabled in ioctls - maybe
> > I'm blind or they are badly translated. Now I look
> > into "Linux Device Drivers", see ch. 6 about ioctls,
> > blocking I/O and RCU, but nothing about preemption
> > disabled again. Maybe this is omited because it's
> > obvious to people who started hacking with earlier
> > kernels?
> 
> ... or maybe it's even more complicated...
> 
> For the time being, I revoke my critique of these books.
> 
> Jarek P. 

Don't rely on books too heavily, they can get out of date
with a simple code change.

The path that I am talking about is the receive skb path. All data
received goes through netif_receive_skb and that does rcu_read_lock().
This is done so that receive protocol list can be used with RCU (lock
free). Since receiving is a time critical path, we want to process
without having to do any locked operations; locked operations cause a
processor force a cache miss and are one of the main CPU overheads.
RCU requires no locked operation, but does prevent preemption.

-- 
Stephen Hemminger <shemminger@osdl.org>
