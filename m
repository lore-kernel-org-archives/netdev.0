From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Sat, 05 Jul 2014 14:14:21 -0700
Message-ID: <1404594861.6384.75.camel@joe-AO725>
References: <1404498697-21978-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1404498697-21978-2-git-send-email-ezequiel.garcia@free-electrons.com>
	 <20140705210359.GA19441@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0069.hostedemail.com ([216.40.44.69]:48292 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751802AbaGEVOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 17:14:25 -0400
In-Reply-To: <20140705210359.GA19441@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-07-05 at 23:03 +0200, Francois Romieu wrote:
> Partial review below.

trivia:

> > diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
[]
> > +static int mvpp2_prs_tcam_first_free(struct mvpp2 *pp2, int start, int end)
> > +{
> > +	int tid;
> > +	bool found = false;
> > +
> > +	if (start < end)
> > +		for (tid = start; tid <= end; tid++) {
> > +			if (!pp2->prs_shadow[tid].valid) {
> > +				found = true;
> > +				break;
> > +			}
> > +		}
> > +	else
> > +		for (tid = start; tid >= end; tid--) {
> > +			if (!pp2->prs_shadow[tid].valid) {
> > +				found = true;
> > +				break;
> > +			}
> > +		}
> 
> Missing parenthsesis in "if ... else ..." block.

Perhaps it's better to use swap if start > end

	if (start > end)
		swap(start, end);

so there's just one loop
