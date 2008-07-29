From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 08:43:29 +0300
Message-ID: <200807290843.29447.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:53638 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbYG2Fnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 01:43:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 2.6.26, iproute2 latest release. All required modules is loaded.
What did i miss or doing wrong?

tc filter add dev ifb0 protocol all basic match "meta(rt_iif eq tap0)" classid 1:100 

tc -s -d filter show dev ifb0
filter parent 1: protocol all pref 49152 basic
filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
  meta(-1 eq -1)

Whatever i try - it doesn't work
./tc filter add dev ifb0 protocol all basic match meta \(rt_iif eq tap0\) classid 1:100

But if i do
tc filter add dev ifb0 protocol all basic match u32\(u32 0x01020300 0xFFFFFF00 at 12\) classid 1:100

i will get everything "right"

filter parent 1: protocol all pref 49151 basic
filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
  u32(01020300/ffffff00 at 12)

Sure i will try to debug and find bug by myself, but i am not sure i can do that :-)
