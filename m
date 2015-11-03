From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: Invoke driver vlan hooks only if device
 is present
Date: Tue, 03 Nov 2015 11:16:33 -0500 (EST)
Message-ID: <20151103.111633.1800653969325047017.davem@davemloft.net>
References: <1446562559-7264-1-git-send-email-padmanabh.ratnakar@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbKCQQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:16:36 -0500
In-Reply-To: <1446562559-7264-1-git-send-email-padmanabh.ratnakar@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
Date: Tue,  3 Nov 2015 20:25:59 +0530

> NIC drivers mark device as detached during error recovery.
> It expects no manangement hooks to be invoked in this state.
> Invoke driver vlan hooks only if device is present.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>

I don't like this.

This approach to solving the issue just peppers checks randomly around
the kernel and the risk for missing cases is very high.  It is also
not clear to me what exactly specifies that these calls are not valid
in such states.

Traditionally we've depended upon the driver to make this kind of check
in it's callback, and that way we don't need to add extra overhead for
everyone at all of these method invokcation points.

Therefore, I would like to see a less dirty, and less error prone
approach to solving this bug.
