From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] Don't destroy the netdev until the vif is
 shut down
Date: Thu, 19 Sep 2013 14:05:13 -0400 (EDT)
Message-ID: <20130919.140513.2047786411565716987.davem@davemloft.net>
References: <1379436368-6882-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	david.vrabel@citrix.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab3ISSFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:05:15 -0400
In-Reply-To: <1379436368-6882-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 17 Sep 2013 17:46:08 +0100

> Without this patch, if a frontend cycles through states Closing
> and Closed (which Windows frontends need to do) then the netdev
> will be destroyed and requires re-invocation of hotplug scripts
> to restore state before the frontend can move to Connected. Thus
> when udev is not in use the backend gets stuck in InitWait.
> 
> With this patch, the netdev is left alone whilst the backend is
> still online and is only de-registered and freed just prior to
> destroying the vif (which is also nicely symmetrical with the
> netdev allocation and registration being done during probe) so
> no re-invocation of hotplug scripts is required.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

I think all of the testing requests have been satisfied so I have
applied this.

But _please_ write a more proper subject line in future patch
submissions.  You have to provide a subsystem prefix in the
subject line, here I added "xen-netback: ", otherwise someone
skimming the shortlog has no idea what area of code this change
touches.

Thanks.
