From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 3/6] cnic: Fix panic in
 cnic_iscsi_nl_msg_recv() when device is down.
Date: Fri, 26 Feb 2010 11:51:14 +1100
Message-ID: <20100226005114.GH3876@verge.net.au>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
 <1267058529-18454-2-git-send-email-mchan@broadcom.com>
 <1267058529-18454-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53984 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318Ab0BZAvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 19:51:16 -0500
Content-Disposition: inline
In-Reply-To: <1267058529-18454-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2010 at 04:42:06PM -0800, Michael Chan wrote:
> Some data structures are freed when the device is down and it will
> crash if an ISCSI netlink message is received.  Add RCU protection
> to prevent this.  In the shutdown path, ulp_ops[CNIC_ULP_L4] is
> assigned NULL and rcu_synchronized before freeing the data
> structures.

Is rcu_assign_pointer() unnecessary in cnic_cm_open()?
It doesn't seem to be followed by rcu_synchronized() and the pointer
doesn't seem to be accessible anywhere else at that time.
