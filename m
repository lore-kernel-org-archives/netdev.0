From: Jonathan McDowell <noodles@earth.li>
Subject: rfkill causes oops with NULL parent device
Date: Mon, 22 Oct 2007 23:10:56 +0100
Message-ID: <20071022221056.GO1880@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from the.earth.li ([193.201.200.66]:49893 "EHLO the.earth.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064AbXJVWkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 18:40:14 -0400
Received: from noodles by the.earth.li with local (Exim 4.63)
	(envelope-from <noodles@earth.li>)
	id 1Ik5U8-0006ps-6m
	for netdev@vger.kernel.org; Mon, 22 Oct 2007 23:10:56 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm trying to add support for the bluetooth device on Toshiba laptops
using rfkill. The device is controlled only via software and doesn't
exist at all unless enabled, at which point it appears on the USB bus.

However, doing something along the lines of:

toshiba_bluetooth_rfkill = rfkill_allocate(NULL, RFKILL_TYPE_BLUETOOTH);
if (toshiba_bluetooth_rfkill != NULL) {
	result = rfkill_register(toshiba_bluetooth_rfkill);
}

causes an oops; the laptop I'm testing on doesn't have serial so it's
hard to capture the backtrace, but it's the call to device_add in
rfkill_register and there's mention of get_device_parent.

This is with 2.6.23. If rfkill *requires* a parent device then I would
have thought it should return an error if passed NULL in _allocate?

J.

-- 
] http://www.earth.li/~noodles/ [] I am Elmer of Borg, be vewy quiet,  [
]  PGP/GPG Key @ the.earth.li   []      I'm assimilating wabbits.      [
] via keyserver, web or email.  []                                     [
] RSA: 4DC4E7FD / DSA: 5B430367 []                                     [
