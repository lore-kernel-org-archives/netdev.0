From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/15] i40e: Add a fallback debug flow for the driver
Date: Wed, 26 Mar 2014 17:17:22 -0400 (EDT)
Message-ID: <20140326.171722.1680025627362836425.davem@davemloft.net>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395857013-7568-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, catherine.sullivan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756448AbaCZVR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:17:26 -0400
In-Reply-To: <1395857013-7568-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 26 Mar 2014 11:03:29 -0700

> From: Anjali Singhai Jain <anjali.singhai@intel.com>
> 
> If the reset fails or the FW is unresponsive instead of failing
> module load, load the module in debug mode. In this mode the interfaces
> don't exit but the user gets limited access to debugfs hooks. These can
> still be used to read/write to registers for debug.
> 
> Change-ID: Ie33da80d2f53aaa18eac816196d981fb7a86a02c
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

We had this discussion.

Register read/write does not belong in debugfs, utilize a portable existing
typed interface to provide this.  Or create one if it doesn't already
exist.

I think you guys put way too much stuff into your debugfs facilities that
really belong in portable interfaces that any driver can mimick.

Do we really want _EVERY_ driver to add register read/write hack code,
duplicated over and over, via debugfs like this?
