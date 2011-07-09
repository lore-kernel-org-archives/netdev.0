From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 20:08:48 -0700
Message-ID: <20110708200848.4529bb0c@s6510.ftrdhcpuser.net>
References: <CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
	<20110708.153258.1997707802176810939.davem@davemloft.net>
	<20110708164128.50155c9c@nehalam.ftrdhcpuser.net>
	<20110708.164751.1543109601226116469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41532 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550Ab1GIDIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 23:08:49 -0400
In-Reply-To: <20110708.164751.1543109601226116469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Jul 2011 16:47:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 8 Jul 2011 16:41:28 -0700
> 
> > What about using murmur hash which has a four byte pass as well.
> >   https://sites.google.com/site/murmurhash/
> 
> I'm trying to avoid multiplies that are not done in hardware on some
> cpus.
> 
> Right now I'm looking at one of Thomas Wang's hashes, referenced on
> Bob Jenkin's hash analysis page:
> 
> u32 hashint(u32 a)
> {
> 	a += ~(a<<15);
> 	a ^=  (a>>10);
> 	a +=  (a<<3);
> 	a ^=  (a>>6);
> 	a += ~(a<<11);
> 	a ^=  (a>>16);
> 
> 	return a;
> }
> 
> It's 15 instructions, and produces better entropy in the low bits of
> the result than the high bits, which is fine for how we'll use this
> thing.

Ok. but you really have sell those Sparc's while they are still
worth something on Ebay :-)
