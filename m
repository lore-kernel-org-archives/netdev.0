From: Ben Greear <greearb@candelatech.com>
Subject: Problem with cxgb, mac-vlans, and UDP checksum offloading.
Date: Tue, 11 Dec 2007 10:25:26 -0800
Message-ID: <475ED616.6070903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Divy Le Ray <divy@chelsio.com>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40609 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbXLKSZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 13:25:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

This is with kernel 2.6.23, plus our hacks, but the mac-vlan logic
is part of the official kernel now.  OS is Fedora 8.  I have applied
patch 1 and 3 of those sent a few weeks ago for the cxgb as well.

While testing NFS on mac-vlans on cxgb, we noticed that
UDP packets have incorrect checksums when sent from
the mac-vlan device on a cxgb interface to another system.  When sending
from a regular ethernet device (cxgb), it works fine.
When we disable rx and tx UDP checksums on the mac-vlan
device, it works fine.  When we use e1000 interfaces (which
also do rx/tx UDP checksumming), mac-vlans & NFS works fine
with mac-vlan rx/tx checksumming on (the default value).

So, there seems something weird about the cxgb NIC when
used with mac-vlans.  Perhaps it is somehow paying attention
to MAC addresses when it determines if it should csum a packet
or not?

If you want to test it yourself, grab the latest iputils package
and create MAC-VLANs like this:

ip link add link eth0 name eth0#0 address 00:11:22:33:44:55 type macvlan


If you would like a packet trace or any other debugging, please
let me know.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

