From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scsi_netlink: Remove dead and buggy code
Date: Sat, 08 Sep 2012 18:51:05 -0400 (EDT)
Message-ID: <20120908.185105.2033125004492160106.davem@davemloft.net>
References: <87pq5xjw4m.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James.Bottomley@parallels.com,
	James.Smart@Emulex.Com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375Ab2IHWvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 18:51:07 -0400
In-Reply-To: <87pq5xjw4m.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 07 Sep 2012 15:39:21 -0700

> 
> The scsi netlink code confuses the netlink port id with a process id,
> going so far as to read NETLINK_CREDS(skb)->pid instead of the correct
> NETLINK_CB(skb).pid.  Fortunately it does not matter because nothing
> registers to respond to scsi netlink requests.
> 
> The only interesting use of the scsi_netlink interface is
> fc_host_post_vendor_event which sends a netlink multicast message.
> 
> Since nothing registers to handle scsi netlink messages kill all of the
> registration logic, while retaining the same error handling behavior
> preserving the userspace visible behavior and removing all of the
> confused code that thought a netlink port id was a process id.
> 
> This was tested with a kernel allyesconfig build which had no problems.
> 
> Cc: James Bottomley <James.Bottomley@parallels.com>
> Cc: James Smart <James.Smart@Emulex.Com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Yeah I can't see anyone, anywhere, using these scsi_send_nl_*()
interfaces at all.

When I get an ACK from the scsi folks I'll add this to net-next,
thanks Eric.
