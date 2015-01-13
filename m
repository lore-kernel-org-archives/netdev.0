From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCHv1 net-next] xen-netback: always fully coalesce guest
 Rx packets
Date: Tue, 13 Jan 2015 14:30:33 +0000
Message-ID: <20150113143033.GN4226@zion.uk.xensource.com>
References: <1421157917-31333-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4181 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbbAMOaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 09:30:35 -0500
Content-Disposition: inline
In-Reply-To: <1421157917-31333-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 02:05:17PM +0000, David Vrabel wrote:
> Always fully coalesce guest Rx packets into the minimum number of ring
> slots.  Reducing the number of slots per packet has significant
> performance benefits (e.g., 7.2 Gbit/s to 11 Gbit/s in an off-host
> receive test).
> 

Good number.

> However, this does increase the number of grant ops per packet which
> decreases performance with some workloads (intrahost VM to VM)

Do you have figures before and after this change?

> /unless/ grant copy has been optimized for adjacent ops with the same
> source or destination (see "grant-table: defer releasing pages
> acquired in a grant copy"[1]).
> 
> Do we need to retain the existing path and make the always coalesce
> path conditional on a suitable version of Xen?
> 

It the new path improves off-host RX on all Xen versions and doesn't
degrade intrahost VM to VM RX that much, I think we should use it
unconditionally.  Is intrahost VM to VM RX important to XenServer?

I don't consider intrahost VM to VM RX a very important use case, at
least not as important as off-host RX. I would expect in a could
environment users would not count on their VMs reside on the same host.
Plus, some could provider might deliberately route traffic off-host for
various reasons even if VMs are on the same host.  (Verizon for one,
mentioned they do that during last year's Xen Summit IIRC).

Others might disagree. Let's wait for other people to chime in.

> [1] http://lists.xen.org/archives/html/xen-devel/2015-01/msg01118.html
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/common.h  |    1 -
>  drivers/net/xen-netback/netback.c |  106 ++-----------------------------------
>  2 files changed, 3 insertions(+), 104 deletions(-)

Love the diffstat!

Wei.
