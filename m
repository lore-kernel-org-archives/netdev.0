From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [bisected] kernel panic 2.6.22 -> 2.6.26-rc9+
Date: Sun, 13 Jul 2008 12:48:15 +0200
Message-ID: <m3abgmcb68.fsf@maximus.localdomain>
References: <m3d4lisk4i.fsf@maximus.localdomain>
	<20080713013107.23f060f2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:53124 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbYGMKsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jul 2008 06:48:17 -0400
In-Reply-To: <20080713013107.23f060f2.akpm@linux-foundation.org> (Andrew Morton's message of "Sun\, 13 Jul 2008 01\:31\:07 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> (cc's added)

(cc added) :-)

> I guess you're referring to this:
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-07/msg04754.html

Right.

>> PPP over ATM connection (Thomson/Alcatel
>> Speedtouch). It doesn't seem to occur on the same IXP4xx with Ethernet
>> or V.35 WAN, and it doesn't occur on i386 + the same Speedtouch ADSL.
>> The kernel is basically unpatched, the only extra patch applied is the
>> platform support (nothing magic).
>> 
>> Generally to trigger the panic one has to request a TCP data stream
>> over that PPPoATM connection.

I see what's wrong now: that's the ARM fls() problem, the call in
fls64() to be precise. It seems it was already discussed: the patch in
http://lkml.org/lkml/2008/5/4/233 makes the problem disappear.

Perhaps it's time to fix it definitely?
-- 
Krzysztof Halasa
