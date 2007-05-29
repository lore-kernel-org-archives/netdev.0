From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Definition and usage of NETIF_F_HW_SUM?
Date: Tue, 29 May 2007 14:58:08 -0700
Message-ID: <20070529145808.3ba8e77a@freepuppy>
References: <20070529135813.63303693@freepuppy>
	<20070529213618.GA9360@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:43310 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbXE2WHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 18:07:32 -0400
In-Reply-To: <20070529213618.GA9360@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 07:36:18 +1000
Herbert Xu <herbert.xu@redhat.com> wrote:

> On Tue, May 29, 2007 at 01:58:13PM -0700, Stephen Hemminger wrote:
> > The flag NETIF_F_HW_SUM is being misused. The definition says that the device
> > is capable of checksumming any packet. When in fact from usage it seems to
> > imply that the device is capable of doing IPV6 as well as IPV4.
> 
> That would be a problem.
> 
> > Some devices like 8139too do "fake checksum offloading" because they always have to copy
> > the packet.
> > 
> > Some devices like via-rhine, don't really checksum but if they see CHECKSUM_PARTIAL then they
> > copy. This is bogus, they should just let higher layer do checksum/copy.
> 
> Actually this is OK because if they have to copy it then it's cheaper to
> checksum it there.  Both of these should be able to support all protocols.
> 
> > Devices like e1000, and bnx2 are broken because they assume only TCP/UDP and IPV4/IPV6. 
> > The definition of the flag says other protocols should work, but they probably send the
> > hardware into a state of confusion.
> 
> I just checked e1000 and it's correct as it does use the csum_offset
> when doing TX offload.  However, you're definitely right that bnx2
> seems to be broken.
> 
> > A few devices take a offset, starting point, and insertion point. This looks like
> > the correct model. But no upper layer protocols other than IPV4/IPV6 can do checksum
> > offload at present, so it seems moot.
> 
> I could easily whip up a patch to get GRE to use it for a start :)
> 
> > IMHO the correct solution would be to get rid if NETIF_F_HW_SUM and make a new flag
> > NETIF_F_IPV6_SUM. Devices that can checksum both could do NETIF_F_IPV4_SUM|NETI_F_IPV6_SUM.
> 
> We should definitely keep NETIF_F_HW_SUM for sane hardware such as the
> e1000.  Unfortunately we may just have to invent IPV6_SUM for the broken
> ones.
> 

The Marvell 88e8071 does IPV4 and IPV6 checksum, earlier chips could do arbitrary
checksum. Looks like when they added the TSO6 logic, they made transmit state machine
more protocol dependent.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
