From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH v2 net-next 3/9] tg3: Reintroduce 5717_PLUS
Date: Wed, 6 Apr 2011 10:33:26 -0700
Message-ID: <20110406173325.GA14870@mcarlson.broadcom.com>
References: <1302049371-13799-4-git-send-email-mcarlson@broadcom.com>
 <1302067853.1683.29.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4104 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab1DFR1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 13:27:09 -0400
In-Reply-To: <1302067853.1683.29.camel@Joe-Laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 10:30:53PM -0700, Joe Perches wrote:
> On Tue, 2011-04-05 at 17:22 -0700, Matt Carlson wrote:
> > This patch reintroduces the TG3_FLG3_5717_PLUS to identify 5717 and
> > later devices.
> []
> > @@ -13427,8 +13422,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> []
> > +	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
> >  		tp->tg3_flags3 |= TG3_FLG3_LRG_PROD_RING_CAP;
> 
> This seems redundant.  Maybe consolidate to just
> TG3_FLG3_5717_PLUS and remove LRG_PROD_RING_CAP?
> 
> I don't know if these attributes really are linked.
> 
> Another option may be to use DECLARE_BITMAP
> and set_bit/test_bit so there's no real need
> to use FLAG/FLG2/FLG3, etc.

A while back, I submitted a patch that extended the rx ring sizes for
those devices that were capable.  Dave Miller commented that he didn't
think the additional buffering was benefitial and in fact had a
downside.  (Larger ring sizes will result in more inefficient cache
usage.)

To fix the problem, the driver will need to be able to easily identify
which devices support the larger ring sizes.  This patch represents a
step in that direction.  Follow-on patches will make more use of the
flag, which should justify its existence.

For the record though, I did consider using the TG3_FLG3_5717_PLUS flag.
I'm uncomfortable with using it here because this is more of a server
class device feature.  Should another mobile or desktop device be
created in the future, I'd have to devise this type of flag to identify
what feature I'm really talking about.  I thought it prudent to just
take care of that now.

(Not that this is a compelling argument, but it also is a handy way to
enable and disable the feature while debugging.)

