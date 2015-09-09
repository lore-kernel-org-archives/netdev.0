From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCHv1 net] xen-netback: require fewer guest Rx slots when not
 using GSO
Date: Wed, 9 Sep 2015 11:41:20 +0100
Message-ID: <20150909104120.GL12714@zion.uk.xensource.com>
References: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40507 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbIIKlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 06:41:22 -0400
Content-Disposition: inline
In-Reply-To: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 08, 2015 at 02:25:14PM +0100, David Vrabel wrote:
> Commit f48da8b14d04ca87ffcffe68829afd45f926ec6a (xen-netback: fix
> unlimited guest Rx internal queue and carrier flapping) introduced a
> regression.
> 
> The PV frontend in IPXE only places 4 requests on the guest Rx ring.
> Since netback required at least (MAX_SKB_FRAGS + 1) slots, IPXE could
> not receive any packets.
> 
> a) If GSO is not enabled on the VIF, fewer guest Rx slots are required
>    for the largest possible packet.  Calculate the required slots
>    based on the maximum GSO size or the MTU.
> 
>    This calculation of the number of required slots relies on
>    1650d5455bd2 (xen-netback: always fully coalesce guest Rx packets)
>    which present in 4.0-rc1 and later.
> 
> b) Reduce the Rx stall detection to checking for at least one
>    available Rx request.  This is fine since we're predominately
>    concerned with detecting interfaces which are down and thus have
>    zero available Rx requests.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
