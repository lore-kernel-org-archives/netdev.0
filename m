From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 0/6] slight optimization of addr compare for
 some modules
Date: Mon, 16 Dec 2013 06:45:11 -0800
Message-ID: <1387205111.18217.7.camel@joe-AO722>
References: <52AEB8B3.5010405@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0200.hostedemail.com ([216.40.44.200]:37143 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754511Ab3LPOpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 09:45:14 -0500
In-Reply-To: <52AEB8B3.5010405@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 16:24 +0800, Ding Tianhong wrote:
> Joe Perches add ether_addr_equal_unaligned to test if
> possibly unaligned to u16 Ethernet addresses are equal.
> 
> If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
> the slightly faster generic routine ether_addr_equal,
> otherwise this uses memcmp.
> 
> So I replace memcmp with ether_addr_equal_unaligned in some place
> for slight optimization.

Hi.

These seem like sensible cleanups, thanks, but
my name doesn't need to go into the commit log
multiple times like this.

I suggest something like:

Use the recently added and possibly more efficient
ether_addr_equal_unaligned.

Are you intending to do more of these?

$ git grep -E "\bmemcmp\s*\([^,]*,[^,]*,\s*(ETH_ALEN|6)\s*\)" * | wc -l
299

Perhaps the majority of these should use ether_addr_equal
or ether_addr_equal_unaligned.
