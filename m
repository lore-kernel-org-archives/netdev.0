From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vsprintf: Remove SPECIAL from pointer types
Date: Mon, 07 Jul 2014 06:26:17 -0700
Message-ID: <1404739577.27043.65.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
	 <1404364565.14741.26.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
	 <1404368746.14741.36.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
	 <1404576420.6384.41.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>
	 <1404583739.6384.51.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>
	 <1404585099.6384.53.camel@joe-AO725>
	 <alpine.LFD.2.11.1407052103130.15455@eddie.linux-mips.org>
	 <1404593114.6384.72.camel@joe-AO725>
	 <063D6719AE5E284EB5DD2968C1650D6D1726D4E1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726D4E1@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-07-07 at 08:26 +0000, David Laight wrote:
> From: Joe Perches
> > Because gcc issues a complaint about any pointer format with %#p,
> > remove the use of SPECIAL to prefix 0x to various pointer types.
> > 
> > There are no uses in the kernel tree of %#p.
> 
> I know you guys don't really care about them, but there might
> be uses in out of tree drivers.
> 
> With the change what is output for %#p ?

Linux's output of %#p for normal, non %p<foo> extension use,
continues to be prefixed with 0x and zero filled.

Prior to this proposed change:
%#p uses a fixed width of sizeof(void *) * 2 + 2.
%p uses a fixed with of sizeof(void *) * 2

Post:
%#p uses a variable width of the minimum of sizeof(void *) * 2
to sizeof(void *) * 2 + 2 depending on the high order 2 bytes
of the pointer value.

There is no in-kernel tree code that uses %#p so it
has no net effect.

Personally, I prefer %#p uses the "+ 2" fixed width.

The real benefit is removing the auto-prefixing of 0x
when using the %pa extension to be consistent with
other naked pointer output types.
