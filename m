From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: use domain based selectors when address
 based selectors are not available
Date: Fri, 02 Aug 2013 16:57:23 -0700 (PDT)
Message-ID: <20130802.165723.552710416990351120.davem@davemloft.net>
References: <20130802184508.22429.94026.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950Ab3HBX51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 19:57:27 -0400
In-Reply-To: <20130802184508.22429.94026.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 02 Aug 2013 14:45:08 -0400

> NetLabel has the ability to selectively assign network security labels
> to outbound traffic based on either the LSM's "domain" (different for
> each LSM), the network destination, or a combination of both.  Depending
> on the type of traffic, local or forwarded, and the type of traffic
> selector, domain or address based, different hooks are used to label the
> traffic; the goal being minimal overhead.
> 
> Unfortunately, there is a bug such that a system using NetLabel domain
> based traffic selectors does not correctly label outbound local traffic
> that is not assigned to a socket.  The issue is that in these cases
> the associated NetLabel hook only looks at the address based selectors
> and not the domain based selectors.  This patch corrects this by
> checking both the domain and address based selectors so that the correct
> labeling is applied, regardless of the configuration type.
> 
> In order to acomplish this fix, this patch also simplifies some of the
> NetLabel domainhash structures to use a more common outbound traffic
> mapping type: struct netlbl_dommap_def.  This simplifies some of the code
> in this patch and paves the way for further simplifications in the
> future.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied, thanks Paul.
