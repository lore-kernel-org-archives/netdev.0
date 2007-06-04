From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: Definition and usage of NETIF_F_HW_SUM?
Date: Mon, 4 Jun 2007 08:35:08 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07BC8CA1@AVEXCH1.qlogic.org>
References: <20070529164542.2a38e2f8@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55924 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbXFDPfp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 11:35:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070529164542.2a38e2f8@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was out of town last week and did not have a chance to respond.  Yes,
qla3xxx is (before Stephen's fix) broken on IPV6.  I will review the
changes and post a patch if necessary. 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> Sent: Tuesday, May 29, 2007 4:46 PM
> To: Michael Chan
> Cc: Herbert Xu; netdev
> Subject: Re: Definition and usage of NETIF_F_HW_SUM?
> 
> On Tue, 29 May 2007 17:10:52 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > On Wed, 2007-05-30 at 07:36 +1000, Herbert Xu wrote:
> > 
> > > 
> > > I just checked e1000 and it's correct as it does use the 
> csum_offset
> > > when doing TX offload.  However, you're definitely right that bnx2
> > > seems to be broken.
> > > 
> > > > A few devices take a offset, starting point, and 
> insertion point. This looks like
> > > > the correct model. But no upper layer protocols other 
> than IPV4/IPV6 can do checksum
> > > > offload at present, so it seems moot.
> > > 
> > > I could easily whip up a patch to get GRE to use it for a start :)
> > > 
> > > > IMHO the correct solution would be to get rid if 
> NETIF_F_HW_SUM and make a new flag
> > > > NETIF_F_IPV6_SUM. Devices that can checksum both could 
> do NETIF_F_IPV4_SUM|NETI_F_IPV6_SUM.
> > > 
> > > We should definitely keep NETIF_F_HW_SUM for sane 
> hardware such as the
> > > e1000.  Unfortunately we may just have to invent IPV6_SUM 
> for the broken
> > > ones.
> > > 
> > > Ccing Michael to see if the bnx2 chip can actually do offset-based
> > > checksum offload.
> > > 
> > 
> > bnx2 and tg3 cannot do offset-based checksumming because 
> the hardware
> > doesn't have room in the buffer descriptors to specify the 
> offsets.  So
> > regrettably, the NETIF_F_HW_SUM flag has been misused in 
> these drivers.
> > A new NETIF_F_IPV6_SUM flag will be very useful for us.
> 
> Look furthur many drivers are just plain broken and use F_HW_SUM
> and can't even do IPV6 properly.  I'll fix
> 
> The worst code award goes to: qla3xxx.c
> which is broken on IPV6 and goes to trouble of computing all the
> offsets and they are already there in skb...
> 
> 
> 
> -- 
> Stephen Hemminger <shemminger@linux-foundation.org>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
