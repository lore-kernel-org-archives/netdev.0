From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2 net] xen: netback: read hotplug script once at start
 of day.
Date: Mon, 1 Jun 2015 12:24:22 +0100
Message-ID: <20150601112422.GB19403@zion.uk.xensource.com>
References: <1433154624-28123-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <david.vrabel@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43959 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461AbbFALY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 07:24:29 -0400
Content-Disposition: inline
In-Reply-To: <1433154624-28123-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 11:30:24AM +0100, Ian Campbell wrote:
> When we come to tear things down in netback_remove() and generate the
> uevent it is possible that the xenstore directory has already been
> removed (details below).
> 
> In such cases netback_uevent() won't be able to read the hotplug
> script and will write a xenstore error node.
> 
> A recent change to the hypervisor exposed this race such that we now
> sometimes lose it (where apparently we didn't ever before).
> 
> Instead read the hotplug script configuration during setup and use it
> for the lifetime of the backend device.
> 
> The apparently more obvious fix of moving the transition to
> state=Closed in netback_remove() to after the uevent does not work
> because it is possible that we are already in state=Closed (in
> reaction to the guest having disconnected as it shutdown). Being
> already in Closed means the toolstack is at liberty to start tearing
> down the xenstore directories. In principal it might be possible to
> arrange to unregister the device sooner (e.g on transition to Closing)
> such that xenstore would still be there but this state machine is
> fragile and prone to anger...
> 
> A modern Xen system only relies on the hotplug uevent for driver
> domains, when the backend is in the same domain as the toolstack it
> will run the necessary setup/teardown directly in the correct sequence
> wrt xenstore changes.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
