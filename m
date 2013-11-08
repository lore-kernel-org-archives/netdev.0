From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix "ip rule delete table 256"
Date: Fri, 08 Nov 2013 14:54:01 -0500 (EST)
Message-ID: <20131108.145401.703012257935119294.davem@davemloft.net>
References: <20131107172638.GA6110@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@networkplumber.org
To: andreas@fatal.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757668Ab3KHTyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 14:54:03 -0500
In-Reply-To: <20131107172638.GA6110@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Henriksson <andreas@fatal.se>
Date: Thu, 7 Nov 2013 18:26:38 +0100

> When trying to delete a table >= 256 using iproute2 the local table
> will be deleted.
> The table id is specified as a netlink attribute when it needs more then
> 8 bits and iproute2 then sets the table field to RT_TABLE_UNSPEC (0).
> Preconditions to matching the table id in the rule delete code
> doesn't seem to take the "table id in netlink attribute" into condition
> so the frh_get_table helper function never gets to do its job when
> matching against current rule.
> Use the helper function twice instead of peaking at the table value directly.
> 
> Originally reported at: http://bugs.debian.org/724783
> 
> Reported-by: Nicolas HICHER <nhicher@avencall.com>
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Good catch, applied and queued up for -stable, thanks!
