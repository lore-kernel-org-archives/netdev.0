From: Patrick McHardy <kaber@trash.net>
Subject: Re: set_multicast_list vs. set_rx_mode
Date: Wed, 15 Aug 2007 14:33:57 +0200
Message-ID: <46C2F2B5.60803@trash.net>
References: <1187181208.3998.44.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37715 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402AbXHOMe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 08:34:28 -0400
In-Reply-To: <1187181208.3998.44.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Is it intentional that in the case where set_rx_mode is assigned, you
> still need to assign set_multicast_list even if it won't ever be called
> as a flag for SIOCADDMULTI?
> 
> I was thinking of converting the wireless code to use set_rx_mode and
> assign set_multicast_list only if the underlying hardware supports
> multicast filtering, and it seems that is well-supported, but it does
> seem a bit weird that set_multicast_list degrades to a flag.


Indeed, I missed that. It should check for !dev->set_multicast_list &&
!dev->set_rx_mode before returning -EINVAL.
