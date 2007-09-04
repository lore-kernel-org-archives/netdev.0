From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH RFC] iw_cxgb3: Support "iwarp-only" interfaces to avoid
 4-tuple conflicts with the host stack.
Date: Tue, 04 Sep 2007 10:13:51 -0500
Message-ID: <46DD762F.80904@opengridcomputing.com>
References: <1187905185.5547.13.camel@stevo-desktop> <adaveawwcpz.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sean.hefty@intel.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:50971 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754515AbXIDPNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 11:13:51 -0400
In-Reply-To: <adaveawwcpz.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Roland Dreier wrote:
>  > The sysadmin creates "for iwarp use only" alias interfaces of the form
>  > "devname:iw*" where devname is the native interface name (eg eth0) for the
>  > iwarp netdev device.  The alias label can be anything starting with "iw".
>  > The "iw" immediately after the ':' is the key used by the iwarp driver.
> 
> What's wrong with my suggestion of having the iwarp driver create an
> "iwX" interface to go with the normal "ethX" interface?  It seems
> simpler to me, and there's a somewhat similar precedent with how
> mac80211 devices create both wlan0 and wmaster0 interfaces.
> 
>  - R.

It seemed much more painful for me to implement. :-)

I'll look into this, but I think for this to be done, the changes must 
be in the cxgb3 driver, not the rdma driver, because the guts of the 
netdev struct are all private to cxgb3.  Remember that this interface 
needs to still do non TCP traffic (like ARP and UDP)...

Maybe you have something in mind here that I'm not thinking about?


Steve.

