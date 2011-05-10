From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Mon, 09 May 2011 19:11:38 -0700
Message-ID: <1304993498.19586.86.camel@Joe-Laptop>
References: <20110510000758.GA12728@x61.tchesoft.com>
	 <23511.1304992840@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: aquini@linux.com, kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1421 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab1EJCLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 22:11:40 -0400
In-Reply-To: <23511.1304992840@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-09 at 19:00 -0700, Jay Vosburgh wrote:
> {
> 	u32 bandwidth;
> 
> 	if (aggregator->num_of_ports) {
> 		switch (...) {
> 		case AD_LINK_SPEED_WHATEVER:
> 			bandwidth = something;
> 			break;
> 		default:
> 			pr_warn or WARN(1, ...);
> 			bandwidth = 0;
> 		}
> 		return bandwidth;
> 	}
> 	return 0;
> }

My preference is to return early and reduce indentation.

It can make things like pr_<foo> or WARN more likely to
fit on a single.

{
	int bandwidth;

	if (!aggregator->num_of_ports)
		return 0;

	switch (...) {
	case FOO:
		bandwidth = bar;
		break;
	...
	}

	return bandwidth;
}


