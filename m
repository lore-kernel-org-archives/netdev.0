From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Mon, 14 Mar 2016 15:56:40 -0400 (EDT)
Message-ID: <20160314.155640.1574437783302725000.davem@davemloft.net>
References: <20160314145144.GE2346@nanopsycho.orion>
	<56E706C3.4030808@cumulusnetworks.com>
	<20160314190435.GA23419@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbcCNT4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:56:43 -0400
In-Reply-To: <20160314190435.GA23419@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 14 Mar 2016 20:04:35 +0100

> I believe that using *any* structs to send over netlink is a mistake.
> Netlink is capable to transfer everything using attrs. Easy to compose,
> easy to parse. easy to extend. Couple of more bytes in the message? So what?
> For newly introduced things, I suggest to do this properly.

It is not so straight-forward.

What to put into the header is a tradeoff.

The most basic use cases should be as efficient as possible, and if we
can put reasonable knobs into the base commend header we should do that
as avoiding attribute processing makes things faster.

And I think in this case it is reasonable to put the mask in there.

The only problem I see with this series is the naming of the netlink
command (it isn't a "new" operation, and the "del" is unused).

Maybe the suggestion to use just "GET" as the name is ok.
