From: Curtis Doty <Curtis@GreenKey.net>
Subject: bug: route metric signing
Date: Wed, 10 Mar 2010 07:41:01 -0800 (PST)
Message-ID: <20100310154101.EB84C6F101@alopias.GreenKey.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: Linux Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alopias.GreenKey.net ([209.209.60.60]:34439 "EHLO
	alopias.GreenKey.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756783Ab0CJP7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:59:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The metric set is not the metric displayed. I'm presuming it's a cosmetic 
error in iproute2?

# ip route add 192.0.2.42 via 127.0.0.1 metric 4294967295
# ip route ls 192.0.2.42
192.0.2.42 via 127.0.0.1 dev lo  metric -1

And...

# ip route add 192.0.2.42 via 127.0.0.1 metric 2147483648
# ip route ls 192.0.2.42
192.0.2.42 via 127.0.0.1 dev lo  metric -2147483648

But this one appears OK...

# ip route add 192.0.2.42 via 127.0.0.1 metric 2147483647
# ip route ls 192.0.2.42
192.0.2.42 via 127.0.0.1 dev lo  metric 2147483647

Test platform is Fedora 12.

# rpm -q iproute
iproute-2.6.29-4.fc12.x86_64

# rpm -q kernel
kernel-2.6.32.9-70.fc12.x86_64

../C

