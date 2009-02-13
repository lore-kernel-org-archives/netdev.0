From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 4/6] igb: misc cleanup to combine one if
	statement and set last_rx
Date: Fri, 13 Feb 2009 13:23:23 +0000
Message-ID: <1234531403.3110.3.camel@achroite>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
	 <20090213041804.3848.73723.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	gospo@redhat.com, Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:54113 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753911AbZBMNXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 08:23:42 -0500
In-Reply-To: <20090213041804.3848.73723.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-12 at 20:18 -0800, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch combines a pair of if statements into one and adds a line to
> update netdev->last_rx.
[...]

You shouldn't need to update last_rx any more:

commit 6cf3f41e6c08bca6641a695449791c38a25f35ff
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Mon Nov 3 18:16:50 2008 -0800

    bonding, net: Move last_rx update into bonding recv logic
    
        The only user of the net_device->last_rx field is bonding.
    This patch adds a conditional update of last_rx to the bonding special
    logic in skb_bond_should_drop, causing last_rx to only be updated when
    the ARP monitor is running.
    
        This frees network device drivers from the necessity of
    updating last_rx, which can have cache line thrash issues.
    
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

