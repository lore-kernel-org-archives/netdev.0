From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/16] net: Implement network device movement between
 namespaces
Date: Wed, 12 Sep 2007 04:54:36 -0700 (PDT)
Message-ID: <20070912.045436.41647007.davem@davemloft.net>
References: <m17in0vo0d.fsf_-_@ebiederm.dsl.xmission.com>
	<m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:55248
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933743AbXILLzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:55:10 -0400
In-Reply-To: <m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:38:46 -0600

> 
> This patch introduces NETIF_F_NETNS_LOCAL a flag to indicate
> a network device is local to a single network namespace and
> should never be moved.  Useful for pseudo devices that we
> need an instance in each network namespace (like the loopback
> device) and for any device we find that cannot handle multiple
> network namespaces so we may trap them in the initial network
> namespace.
> 
> This patch introduces the function dev_change_net_namespace
> a function used to move a network device from one network
> namespace to another.  To the network device nothing
> special appears to happen, to the components of the network
> stack it appears as if the network device was unregistered
> in the network namespace it is in, and a new device
> was registered in the network namespace the device
> was moved to.
> 
> This patch sets up a namespace device destructor that
> upon the exit of a network namespace moves all of the
> movable network devices  to the initial network namespace
> so they are not lost.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24
