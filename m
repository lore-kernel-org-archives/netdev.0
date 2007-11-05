From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 5 Nov 2007 15:35:36 +0100
Message-ID: <20071105143536.GC1933@ff.dom.local>
References: <1193939701.2987.82.camel@localhost.localdomain> <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost> <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl> <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost> <20071105091231.GA1933@ff.dom.local> <1194270426.4438.100.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:54256 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755482AbXKEObu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 09:31:50 -0500
Content-Disposition: inline
In-Reply-To: <1194270426.4438.100.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2007 at 08:47:06AM -0500, jamal wrote:
> On Mon, 2007-05-11 at 10:12 +0100, Jarek Poplawski wrote:
> 
> > BTW: when looking around this I think, maybe, in u32_change():
> > 
> > 1) if (--divisor > 0x100) should be probably ">=", 
> 
> Does it really matter? Divisor can be max of 0xff.

But, according to this max is 0x100... It doesn't really matter,
but we have to wonder which one check is correct if they differ.

> 
> > but is it really needed to check this 2 times (including tc)?
> 
> I dont mind letting users shoot themselves in the foot by sending crap.
> If it can be avoided with simplicity, then better.
> 
> > 2) this while() loop for n->fshift could be replaced with ffs()?
> 
> I think so. Can you please send a patch (after some testing of course
> maybe using Radu's test data)?

Since this would be cosmetics here, I think it could wait for this
main patch. But, since testing isn't my best side, maybe I'd ask
Radu for including this "btw"... I mean only something like this:

  {
  	u8 i = 0;
  	u32 mask = s->hmask;
  	if (mask) {
- 		while (!(mask & 1)) {
- 			i++;
- 			mask>>=1;
- 		}
		i = ffs(mask) + 1;
  	}
  	n->fshift = i;
  }

Thanks,
Jarek P.
