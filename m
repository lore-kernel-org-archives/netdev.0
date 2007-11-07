From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Wed, 07 Nov 2007 15:55:31 +0200
Message-ID: <1194443731.2987.232.camel@localhost.localdomain>
References: <20071106142558.GC1666@ff.dom.local>
	 <1194360226.4444.39.camel@localhost>
	 <1194368416.2987.218.camel@localhost.localdomain>
	 <20071107.012220.17723288.davem@davemloft.net>
	 <1194442968.4446.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@o2.pl,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:40962 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756516AbXKGN6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 08:58:21 -0500
In-Reply-To: <1194442968.4446.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-11-07 at 08:42 -0500, jamal wrote:
> On Wed, 2007-07-11 at 01:22 -0800, David Miller wrote:
> 
> > @@ -615,7 +615,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
> >  	n->handle = handle;
> >  {
> >  	u8 i = 0;
> > -	u32 mask = s->hmask;
> > +	u32 mask = ntohl(s->hmask);
> 
> 
> Is this line needed? Radu?

Yup. Without it, the number of bits to shift would be computed on the
network ordered mask. The shift in u32_hash_fold() is done on a host
ordered u32 (obtained from applying the mask on the packet data).

Shifting the host ordered u32 with number of bits obtained from network
ordered mask would most probably break things.

I've just compiled the kernel from a fresh clone of Dave's tree (u32
patch included) and I'm about to test it.

Dave, thanks a lot for adding the patch to your tree. But I guess you
didn't test it. I'll get back to you in max 1 hour and tell you the
results.

If everything goes well, then I'll move on to testing the ffs() patch.

Cheers,

Radu


