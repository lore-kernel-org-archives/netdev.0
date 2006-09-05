From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2: hw checksum failures
Date: Tue, 5 Sep 2006 14:31:03 -0700
Message-ID: <20060905143103.15842e07@localhost.localdomain>
References: <1157416603.22705.62.camel@localhost.localdomain>
	<20060904203442.1c9ed2eb@localhost.localdomain>
	<1157427758.22705.65.camel@localhost.localdomain>
	<20060904205645.6c80f30c@localhost.localdomain>
	<1157431548.22705.78.camel@localhost.localdomain>
	<44FD90FC.4090409@osdl.org>
	<1157490763.22705.130.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21894 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751305AbWIEVbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 17:31:20 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157490763.22705.130.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Sep 2006 07:12:43 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> > > Which means that if it worked on x86 with le16_to_cpu, it should work on
> > > powerpc... The main difference here however is that you called
> > > le16_to_cpu (which is basically a nop) on a 32 bits field, while I
> > > called le32_to_cpu() on it. But both should lead to the same ... (x86
> > > will do a swapped 16 bits load of the 2 first bytes, while ppc will do a
> > > load of 4 bytes and swap that, thus ending up with the first 2 bytes
> > > swapped in the low order of the result). I'll dump the values and have a
> > > look to be sure. Another possibility would be a problem with the bits
> > > telling the chip where to calculate the checksum.
> > >   
> > Hardware only computes 16 bit checksum.
> 
> Oh I know that, but calling 16 bits swapping macros on a 32 bits field
> is a bit dodgy... might work in this case, I'll verify, but you may end
> up with the wrong half of the 32 bits word being used :)
> 
> Ben.
> 
> 

Agreed. Actually the checksum value is same hi/lo because there are
two checksum units and we ask for the same offset on both.

-- 
Stephen Hemminger <shemminger@osdl.org>
