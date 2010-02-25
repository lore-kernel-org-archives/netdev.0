From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Wed, 24 Feb 2010 20:42:07 -0500
Message-ID: <20100225014207.GB10527@localhost.localdomain>
References: <29C1DC0826876849BDD9F1C67ABA2943070F0E2E@ala-mail09.corp.ad.wrs.com>
 <20100224185340.GB15380@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
 <20100224.173436.212403104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41720 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758711Ab0BYBmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 20:42:14 -0500
Content-Disposition: inline
In-Reply-To: <20100224.173436.212403104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2010 at 05:34:36PM -0800, David Miller wrote:
> From: "Stephens, Allan" <allan.stephens@windriver.com>
> Date: Wed, 24 Feb 2010 11:05:12 -0800
> 
> > Have you tried upgrading your system to use TIPC 1.7.6 (available at
> > http://tipc.sourceforge.net/tipc_linux.html)?  This is a significant
> > revised and enhanced version of TIPC that hasn't yet made its way into
> > mainsteam Linux, and seems to be the version-of-choice for most TIPC
> > users.  It also appears to avoid a number of the issues that currently
> > exist in TIPC 1.6, including the one caused by the random configuration
> > command you mentioned in your email below.
> > 
> > I didn't have a problem with you working on a small patch for TIPC 1.6
> > to get around a limited problem, but I'd hate to see you waste time on
> > fixing issues that have already been addressed in TIPC 1.7.
> 
> Why is the TIPC kernel protocol code being developed out of tree
> instead of directly upstream?
> 
> Regardless of that, if the code is in the kernel tree and it can be
> OOPS'd, we must fix it.
> 
Agreed, with a combination of:
1) The patch which Allan posted to check tipc_net.zone and tipc_local_nodes for
being NULL in tipc_select_node

2) The patch that I asked Allan to extract from the sourceforge package which
adds checks for TIPC_NET_MODE in the appropriate places

3) The patch I posted to close the race in the setting of tipc_mode

we should fix all the oopses I've found so far.

Ideally it would seem what would be most appropriate would be to wholesale
import tipc 1.7.6 from sourceforge to the kernel to get all the fixes that have
gone in there.  That seems like its been waiting in the wings for over a year
now.

Neil

