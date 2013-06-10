From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/1] alx driver
Date: Mon, 10 Jun 2013 23:26:48 +0200
Message-ID: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
Cc: mcgrof@do-not-panic.com, kvalo@adurom.com, adrian.chadd@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:34892 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816Ab3FJV07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 17:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So ... I was stupid enough to not research drivers for this device
before buying a board that included one, I figured in 2013 it wasn't
really possible for such a simple gigabit ethernet device to not
have a driver in Linux.

Boy was I wrong.

The vendor driver was previously posted on netdev, and subsequently
somewhat cleaned up, but ... it still had useless hand-rolled locks
(with test_and_set_bit/msleep!), horrible macros, and was generally
quite a mess.

I do have to admit that I'm not very familiar with all the netdev
APIs, since wireless devices are so slow that NAPI etc. hardly
matters. In a way, this is also me learning about it since we'll be
betting faster wireless too :-)

I hope I did an OK job at cleaning it up/rewriting it, but while I
thought about the locking for a while, or rather the lack thereof,
I'm not entirely sure that it's completely safe. It seemed to me
that since we have TX/RX all done from NAPI it won't actually have
to be reentrant/locked.

Also, I kept the FIELD macros, which seemed wrong at first but the
code didn't get nicer w/o them. I did fix them for endianness and
converted some to inlines; I don't get why they actually had endian
annotations and even turned on the sparse checks by default only to
then ignore all the errors it was giving. I'll happily kill these
if anyone thinks that would be better.

Anyway, as I said, I'm not very good at ethernet drivers, so let me
know what I need to fix.

Maybe the responsible QCA folks can actually add back the features
that I liberally pruned from the driver.

johannes
