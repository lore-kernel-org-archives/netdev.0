From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 18212] New: force_igmp_version ignored when a IGMPv3
	query received (+1 line patch)
Date: Wed, 15 Sep 2010 10:02:40 +0800
Message-ID: <20100915020240.GA19372@gondor.apana.org.au>
References: <20100910091936.75eabbf6@nehalam> <OF1A09F28B.15E7E7BC-ON8825779E.00741A65-8825779E.007540E3@us.ibm.com> <20100914.142418.149835514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36411 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094Ab0IOCCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 22:02:51 -0400
Content-Disposition: inline
In-Reply-To: <20100914.142418.149835514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 02:24:18PM -0700, David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Tue, 14 Sep 2010 14:20:40 -0700
> 
> > netdev-owner@vger.kernel.org wrote on 09/10/2010 09:19:36 AM:
> > 
> >> 
> >> https://bugzilla.kernel.org/show_bug.cgi?id=18212
> >> 
> >>            Summary: force_igmp_version ignored when a IGMPv3 query
> >>                     received (+1 line patch)
> > 
> >> 
> >> Created an attachment (id=29512)
> >>  --> (https://bugzilla.kernel.org/attachment.cgi?id=29512)
> >> fix force_igmp_version v3 query problem
> >> 
> >> After all these years, it turns out that the
> >>     /proc/sys/net/ipv4/conf/*/force_igmp_version
> >> parameter isn't fully implemented.
> > 
> >         I don't think it's correct to send a v2 response to a v3
> > query in any case. The question for answering v3 queries was
> > whether to answer them with a v3 report, or to drop them and
> > ignore them when force_igmp_version==2. I chose to respond,
> > but I can see the case for dropping it too. I don't agree that
> > a v3 query should be answered with a v2 resport (a real v2
> > host would drop it).
> 
> Do you have an alternative patch to suggest?

I have gone through both IGMPv2/v3 RFCs and can't find anything
that forbids an IGMPv2 host from replying with a v2 report to a
v3 query.  On the other hand I think dropping the v3 query is also
allowed.

For interoperability, it would seem slightly better to reply with
a v2 report, although I will defer to David Stevens on this :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
