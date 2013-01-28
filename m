From: Johannes Berg <johannes@sipsolutions.net>
Subject: TCP connection in suspend (to RAM)
Date: Mon, 28 Jan 2013 12:55:45 +0100
Message-ID: <1359374145.8120.8.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:42172 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab3A1LzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 06:55:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm working on a feature by which our device (Intel WiFi) will establish
a TCP connection while the host is asleep, in order to receive a wakeup
signal over the connection. There are a few configuration parameters,
but it's basically pretty simple, it establishes a connection, sending
configurable data in a configurable interval on it and wakes up the host
if it receives (certain) data on the connection or the connection breaks
(or we get disconnected from the AP, yadda yadda.)

The implementation is complex, but I've narrowed the configuration down
to configuring the IP addresses (v4 only), ports, and the data related
parameters like the interval etc.

I have two questions:
 1) I'm currently making userspace configure the destination/gateway MAC
    address. I could look up the route at configuration time, but it
    might have changed by the time we suspend and use it. At suspend
    time, I can no longer look up the route since that might require ARP
    queries. Does that seem reasonable, or is there a trick I could use?

 2) I'm making userspace configure the source port, and while some
    special cases might want this it seems like normally the kernel
    should pick an unused port. Does it seem acceptable to create a
    socket at configuration time, use inet_csk_get_port() to get an
    unused port and hang on to it until the configuration is removed
    again some time later (after suspend/resume)?

Thanks,
johannes
