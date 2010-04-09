From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Give a chance for the uio device to be opened
 before failing the path request
Date: Fri, 09 Apr 2010 15:49:45 -0700 (PDT)
Message-ID: <20100409.154945.118937724.davem@davemloft.net>
References: <1270762468-21128-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, waie@broadcom.com
To: benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292Ab0DIWtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 18:49:43 -0400
In-Reply-To: <1270762468-21128-1-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Benjamin Li" <benli@broadcom.com>
Date: Thu, 8 Apr 2010 14:34:28 -0700

> There is a timing condition; where the time between the CNIC's
> /dev/uio* device registration and then the issuing of path requests
> messages is faster the brcm_iscsiuio daemon initializing.
> 
> This can be seen if one sets the machine to automatically login into
> iSCSI targets.  Then reset the network and iscsi daemons in quick
> succession.  The login will fail because iscsid will only try
> a couple of times in quick succession.  This patch will allow some
> additional needed time for the brcm_iscsiuio daemon to initialize
> before failing the path request call.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Eddie Wai <waie@broadcom.com>

You need to create a proper serialization scheme to fix this.

Any delay value you choose is arbitrary, and could be easily exceeded
if swapping or other expensive operations are in propgress at the time
of the regristration.

Therefore all delay based schemes have a failure mode and therefore
isn't the way to fix this properly.
