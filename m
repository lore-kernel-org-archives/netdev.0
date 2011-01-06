From: Alex Dubov <oakad@yahoo.com>
Subject: Bad TCP timestamps on non-PC platforms
Date: Wed, 5 Jan 2011 22:55:43 -0800 (PST)
Message-ID: <219643.83181.qm@web37604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37604.mail.mud.yahoo.com ([209.191.87.87]:32860 "HELO
	web37604.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753702Ab1AFHC1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 02:02:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings.
I'm dealing with 2.6.37-rc7 kernel on MPC8548 platform.

It so appears, that recent kernels have sysctl_tcp_timestamps set to "1"
by default.

On embedded platforms, where real time clock is initialized lately or
absent outright, this causes TSval field of outgoing TCP packets to be
set to some garbage value, in my case in the vicinity of 0xffffffff. As a
result, other Linux machines silently drop such packets, preventing normal
completion of network boot or any other TCP dependent operation.

Therefore, I feel, two changes are necessary (I can send in a patch):
1. Make sysctl_tcp_timestamps value config-time selectable (it must be
disabled by default on machines without RTC).
2. When re-enabling tcp_timestamps through sysctl, reset the timestamp
counter to the current system clock value.

And an optional, tricky one:
3. Postpone TCP timestamp counter initialization until RTC is actually
available (if RTC is connected to i2c bus, TCP is initialized well ahead
of it).



      
