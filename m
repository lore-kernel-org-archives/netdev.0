From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCHv1 net-next] xen-netback: always fully coalesce guest
 Rx packets
Date: Tue, 20 Jan 2015 11:34:06 +0000
Message-ID: <1421753646.10440.228.camel@citrix.com>
References: <1421157917-31333-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43373 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbbATLeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 06:34:08 -0500
In-Reply-To: <1421157917-31333-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-13 at 14:05 +0000, David Vrabel wrote:
> Always fully coalesce guest Rx packets into the minimum number of ring
> slots.  Reducing the number of slots per packet has significant
> performance benefits (e.g., 7.2 Gbit/s to 11 Gbit/s in an off-host
> receive test).
> 
> However, this does increase the number of grant ops per packet which
> decreases performance with some workloads (intrahost VM to VM)
> /unless/ grant copy has been optimized for adjacent ops with the same
> source or destination (see "grant-table: defer releasing pages
> acquired in a grant copy"[1]).
> 
> Do we need to retain the existing path and make the always coalesce
> path conditional on a suitable version of Xen?
> 
> [1] http://lists.xen.org/archives/html/xen-devel/2015-01/msg01118.html
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Looks good to me, thanks. Based on that plus the conversation in the
other subthread:

Acked-by: Ian Campbell <ian.campbell@citrix.com>
