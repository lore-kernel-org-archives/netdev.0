From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Definition and usage of NETIF_F_HW_SUM?
Date: Tue, 29 May 2007 17:10:52 -0700
Message-ID: <1180483852.9711.28.camel@dell>
References: <20070529135813.63303693@freepuppy>
 <20070529213618.GA9360@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"netdev" <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3438 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbXE2XV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 19:21:29 -0400
In-Reply-To: <20070529213618.GA9360@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-30 at 07:36 +1000, Herbert Xu wrote:

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
> Ccing Michael to see if the bnx2 chip can actually do offset-based
> checksum offload.
> 

bnx2 and tg3 cannot do offset-based checksumming because the hardware
doesn't have room in the buffer descriptors to specify the offsets.  So
regrettably, the NETIF_F_HW_SUM flag has been misused in these drivers.
A new NETIF_F_IPV6_SUM flag will be very useful for us.


