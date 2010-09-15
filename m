From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Bug 18212] New: force_igmp_version ignored when a IGMPv3	query
 received (+1 line patch)
Date: Wed, 15 Sep 2010 02:33:53 -0700
Message-ID: <OF1B791AE0.746C5AF2-ON8825779F.003251E3-8825779F.00348B8A@us.ibm.com>
References: <20100910091936.75eabbf6@nehalam> <OF1A09F28B.15E7E7BC-ON8825779E.00741A65-8825779E.007540E3@us.ibm.com> <20100914.142418.149835514.davem@davemloft.net> <20100915020240.GA19372@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, shemminger@linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:39541 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab0IOJd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 05:33:56 -0400
In-Reply-To: <20100915020240.GA19372@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 09/14/2010 07:02:40 PM:

> From: Herbert Xu <herbert@gondor.apana.org.au>

 
> I have gone through both IGMPv2/v3 RFCs and can't find anything
> that forbids an IGMPv2 host from replying with a v2 report to a
> v3 query.  On the other hand I think dropping the v3 query is also
> allowed.
> 
> For interoperability, it would seem slightly better to reply with
> a v2 report, although I will defer to David Stevens on this :)

Herbert, I don't think "forbids" applies -- there's nothing that
suggests you would answer a v3 query with anything but a v3 report.

Ordinarily, hosts listen and switch to v2 if a v2 querier is present.
The intent is that if anyone can't support v3, then everyone falls
back to v2 (and similarly with v1), and with the loss of functionality
provided by the higher version number.

In this case, a switch that sees v2 queries from the other switch is
still sending a v3 query itself. To me, that's a broken switch. The
v2 switch can do queries of its own, too; answering a v3 query doesn't
forbid answering a v2 query (with a v2 report) should one come in.

So, really, it seems like a hack to me specific to this broken v3
switch. It should send v2 queries because the v2 switch is present;
then linux would answer with a v2 query and everyone would see it.
A host that only supports v2 will not correctly work with this set-up
either -- the v3-only query part is broken, not linux.

My recommendation would be not to mix this v3 switch with v2-only
switches and/or report the v3-only queries as a bug to the switch
vendor. Once you see a v2 query, everyone should switch to v2.

                                                                +-DLS

