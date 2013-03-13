From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 05/22] cxgb4: Add T5 write combining support
Date: Wed, 13 Mar 2013 15:43:13 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B718B@saturn3.aculab.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com> <1363088794-31453-6-git-send-email-vipul@chelsio.com> <20130312.081927.1036246728528667686.davem@davemloft.net> <513F3EBD.5020504@opengridcomputing.com> <51408ED4.40400@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<roland@purestorage.com>, <JBottomley@parallels.com>,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>,
	"Naresh Kumar Inna" <naresh@chelsio.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Santosh Rastapur" <santosh@chelsio.com>,
	"Arvind Bhushan" <arvindb@chelsio.com>,
	"Abhishek Agrawal" <abhishek@chelsio.com>
To: "Vipul Pandya" <vipul@chelsio.com>,
	"Steve Wise" <swise@opengridcomputing.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <51408ED4.40400@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>> +				writel(n,  adap->bar2 + q->udb + 8);
> >>> +#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
> >>> +			asm volatile("sfence" : : : "memory");
> >>> +#endif
> >> There is absolutely no way I'm letting anyone put crap like this
> >> into a driver.
> >>
> >> Use a portable inteface, and if one does not exist create one.
> >
> > I guess you'll have to add a wc_wmb() function for all the hw platforms
> > supported by the kernel.  I see libibverbs defines this for the user
> > side in include/infiniband/arch.h, and that could be used as the meat of
> > the hw platform-specific implementations.
> >
> I see that normal wmb() code for x86_64 architecture is same as what
> above #ifdef condition is doing. To be more clear I looked at the
> assembly code for wmb and find that it is converted into 'sfence'
> instruction. So, I think above code should be replaced with wmb call
> which will also take care of portability on different architecture. I
> will submit the series again soon.

>From my recollection of the x86 architecture, the memory barriers
are hardly ever needed, certainly not in the places where, for example
a ppc needs them. I'd actually suspect that the normal wmb() for
x86 should be a nop.

About the only place where any on the fence instructions are needed
are in relation to write combining accesses.
In particular I don't believe they are ever needed to synchronise
uncached accesses with each other, or with cached accesses (which
are snooped).

	David




