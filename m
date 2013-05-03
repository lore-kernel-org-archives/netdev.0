From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 03 May 2013 08:02:36 -0700
Message-ID: <1367593356.29805.37.camel@edumazet-glaptop>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <1367372393.22115.6.camel@pasglop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7226@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>,
	linuxppc-dev@lists.ozlabs.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37521 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762450Ab3ECPCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 11:02:45 -0400
Received: by mail-pa0-f41.google.com with SMTP id rl6so973974pac.0
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 08:02:44 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7226@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 15:29 +0100, David Laight wrote:
> > > Could ppc64 experts confirm using byte is safe, or should we really add
> > > a 32bit hole after the spinlock ? If so, I wonder how many other places
> > > need a change...
> ...
> > Also I'd be surprised if ppc64 is the only one with that problem... what
> > about sparc64 and arm64 ?
> 
> Even x86 could be affected.
> The width of the memory cycles used by the 'bit set and bit clear'
> instructions isn't documented. They are certainly allowed to do
> RMW on adjacent bytes.
> I don't remember whether they are constrained to only do
> 32bit accesses, but nothing used to say that they wouldn't
> do 32bit misaligned ones! (although I suspect they never have).

x86 is not affected (or else we would have found the bug much earlier)

Setting 1-bit field to one/zero uses OR/AND instructions.

orb  $4,724(%reg)

doesn't load/store 64bits but 8bits.
