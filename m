From: "Tarr, Stephen F" <Stephen.Tarr@xerox.com>
Subject: RE: IPv6 and link state transitions
Date: Fri, 14 Nov 2008 22:04:24 -0800
Message-ID: <78EAC2D97114034EB62AAA10FCC251060543F924@USA7061MS01.na.xerox.net>
References: <78EAC2D97114034EB62AAA10FCC2510608047D83@USA7061MS01.na.xerox.net> <20081114152840.41c0b6c6@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wvmler3.mail.xerox.com ([13.8.138.218]:34233 "EHLO
	wvmler3.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbYKOGYE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 01:24:04 -0500
Received: from wvmlir1.mail.xerox.com (wvmlir1.mail.xerox.com [13.147.8.221])
	by wvmler3.mail.xerox.com (8.14.2/8.13.8) with ESMTP id mAF64WWf012333
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 22:04:32 -0800
Received: from wvmlir1.mail.xerox.com (localhost.localdomain [127.0.0.1])
	by wvmlir1.mail.xerox.com (8.14.2/8.13.6) with ESMTP id mAF64PFc028525
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 22:04:25 -0800
Received: from USA0300GW002.na.xerox.net (usa0300gw002.na.xerox.net [13.135.210.15])
	by wvmlir1.mail.xerox.com (8.14.2/8.13.6) with ESMTP id mAF64PES028519
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 22:04:25 -0800
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Driver should not use set_bit directly.
> The correct way for a driver that has carrier to work is
> 
> mydrvr_open(struct net_device *dev)
> {
> ...
> 	if (mydrv_phy_isoffline(dev))
>               netif_carrier_off(dev);
> ...
> }
> 
> mydrv_phy_intr(...) {
>     if (mydrv_phy_isoffline(dev))
>           netif_carrier_off(dev);
>     else
>           netif_carrier_on(dev)
> }

I actually tried that first, but that led to an extraneous
up/down transition during initialization and (at least sometimes)
extra packets transmitted after the link came up.
Is there some other way to set the initial link state during
initialization -- before the NETDEV_UP event is sent and
without triggering an extra NETDEV_DOWN?  And should it really
be the specific mac or phy driver or the generic phy code that
sets that state?

-Steve Tarr

