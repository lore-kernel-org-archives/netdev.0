From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Need help with MCS7830 driver and 802.1q VLAN Tagging
Date: Thu, 7 Aug 2008 17:36:17 +0200
Message-ID: <20080807153617.GA4001@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.68.41]:38587 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbYHGQKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 12:10:24 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.69)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1KR7XF-0001sL-Q6
	for netdev@vger.kernel.org; Thu, 07 Aug 2008 17:36:17 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am having difficulties with the MCS7830 driver in recent Linux
versions (last version I tried was 2.6.26.1, didn't try 2.6.26.2 yet).
It looks like the MCS7830 has an issue which prevents VLAN tagged
ethernet frames from being transmitted and/or received when the frame
size is near the ethernet MTU.

This behavior was known around the millennium for a lot of ethernet
drivers (including tulip) drivers. The host OS does not know that the
frame is destined to go out via a VLAN tagged interface and thus
builds frames with a size of up to 1500 octets. Then the VLAN tag gets
added, which results in a 1504 octet frame, which seems to be dropped
either by the MCS7830 hardware or its driver.

In some drivers, all was necessary to repair this was to replace a
1500 byte buffer size with 1504; on other interfaces it is necessary
to differently configure the chip.

The MCS7830 does 802.1q with smaller MTUs just fine, and passes tagged
frames. It only fails when the size is larger than MTU-3.

Arnd Bergmann, the original author of the MCS7830 does not have the
resources to debug this at the moment, and unfortunately, my low-level
programming skills are next to existent. I can apply patches,
recompile and try, since i have the hardware available. Can anybody
help with the code?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
