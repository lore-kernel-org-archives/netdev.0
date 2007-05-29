From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Definition and usage of NETIF_F_HW_SUM?
Date: Tue, 29 May 2007 16:45:42 -0700
Message-ID: <20070529164542.2a38e2f8@freepuppy>
References: <20070529135813.63303693@freepuppy>
	<20070529213618.GA9360@gondor.apana.org.au>
	<1180483852.9711.28.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert.xu@redhat.com>,
	"netdev" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:46316 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbXE2X4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 19:56:36 -0400
In-Reply-To: <1180483852.9711.28.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 17:10:52 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> On Wed, 2007-05-30 at 07:36 +1000, Herbert Xu wrote:
> 
> > 
> > I just checked e1000 and it's correct as it does use the csum_offset
> > when doing TX offload.  However, you're definitely right that bnx2
> > seems to be broken.
> > 
> > > A few devices take a offset, starting point, and insertion point. This looks like
> > > the correct model. But no upper layer protocols other than IPV4/IPV6 can do checksum
> > > offload at present, so it seems moot.
> > 
> > I could easily whip up a patch to get GRE to use it for a start :)
> > 
> > > IMHO the correct solution would be to get rid if NETIF_F_HW_SUM and make a new flag
> > > NETIF_F_IPV6_SUM. Devices that can checksum both could do NETIF_F_IPV4_SUM|NETI_F_IPV6_SUM.
> > 
> > We should definitely keep NETIF_F_HW_SUM for sane hardware such as the
> > e1000.  Unfortunately we may just have to invent IPV6_SUM for the broken
> > ones.
> > 
> > Ccing Michael to see if the bnx2 chip can actually do offset-based
> > checksum offload.
> > 
> 
> bnx2 and tg3 cannot do offset-based checksumming because the hardware
> doesn't have room in the buffer descriptors to specify the offsets.  So
> regrettably, the NETIF_F_HW_SUM flag has been misused in these drivers.
> A new NETIF_F_IPV6_SUM flag will be very useful for us.

Look furthur many drivers are just plain broken and use F_HW_SUM
and can't even do IPV6 properly.  I'll fix

The worst code award goes to: qla3xxx.c
which is broken on IPV6 and goes to trouble of computing all the
offsets and they are already there in skb...



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
