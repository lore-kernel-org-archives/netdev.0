From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Tue, 4 Feb 2014 23:08:09 +0100
Message-ID: <20140204220809.GB7526@sesse.net>
References: <20140118191107.GA21979@sesse.net>
 <20140119181806.GC16462@order.stressinduktion.org>
 <20140120184025.GA19972@sesse.net>
 <20140130104709.GA21178@sesse.net>
 <20140130180304.GA3793@plex.lan>
 <20140130181229.GA32245@sesse.net>
 <20140130224411.GG25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:52978 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933973AbaBDWIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 17:08:12 -0500
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1WAoA5-0003SU-Oz
	for netdev@vger.kernel.org; Tue, 04 Feb 2014 23:08:10 +0100
Received: from sesse by pannekake.samfundet.no with local (Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1WAoA5-0003sR-Et
	for netdev@vger.kernel.org; Tue, 04 Feb 2014 23:08:09 +0100
Content-Disposition: inline
In-Reply-To: <20140130224411.GG25336@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 11:44:11PM +0100, Hannes Frederic Sowa wrote:
> The routing lookup is done at IP_ADD_MEMBERSHIP time. I really wonder why you
> have routed the 239.0.0.0/8 range to eth0.11. It seems to me that the kernel
> does what you told it to do. ;)
> 
> multicast flag on ip route is just used for multicast forwarding and does not
> matter for local multicast. Also if we find unicast route first (more
> specific) kernel does not do backtracking if destination is in multicast
> scope.

Hah, you're right. The issue was a combination of:

 1. mediatomb's initscript on Debian at some point started to add a bogus
    239.0.0.0/8 route (and I didn't notice this because I earlier tested with
    addresses outside this range).
 2. I didn't properly understand that the multicast flag on the route did not
    matter (although it really should!).
 3. rp_filter ate the data packets when they actually arrived. (I don't know
    why I never had this problem before, but I certainly didn't.)

So in various debugging rounds, I managed to fix #1 and #2 to various
degrees, but then #3 would come and make it appear like nothing actually
happened. I didn't see this before tracking it all the way up to the upstream
routers and observing that they actually _did_ send out packets...

/* Steinar */
-- 
Homepage: http://www.sesse.net/
