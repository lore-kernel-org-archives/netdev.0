From: Gertjan Hofman <gertjan_hofman@yahoo.com>
Subject: VLAN & ARP requests fail for ARM EABI (2.6.24)
Date: Wed, 9 Apr 2008 15:06:48 -0700 (PDT)
Message-ID: <293225.82676.qm@web32605.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web32605.mail.mud.yahoo.com ([68.142.207.232]:40101 "HELO
	web32605.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754052AbYDIWNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 18:13:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sirs,

Since the VLAN mailing list is closed, its author suggested I post here. 
We have an ARM920T processor based system. When compiling the kernel 2.6.24 using OABI (and appropiate 4.1.1 cross toolchain), VLAN functionality is fine. When setting the CONFIG_EABI flag and using  the 4.2.2 toolchain (created by the OpenEmbedded project) a VLAN device fails to respond.

When pinging through the ARM VLAN device to a (PC based) VLAN device, the following is seen in the vlan driver:
The ping request is sent out, followed by an ARP request. The PC returns the ARP reply and it is seen by the VLAN driver (vlan_skb_recv) which calls netif_rx(). This repeats a couple of pings later i.e. the arp reply is not used or received properly.

Similarly, when pinging from the PC, the ARP request is seen by vlan_skb_recv() but there is no ARP reply from the ARM cascading through the vlan driver.

It seems to me that either the issue is with the code that handles the ARP request when compiling in EABI format, or that VLAN doesnt process the frame properly and sends it on incorrectly. Recompile the kernel with OABI and everything is fine.

Note that communication works fine on either OABI or EABI when using 'normal' devices (eth0 etc). This puts the suspicion back on vlan.


Since EABI changes structure packing and other things, I suspect the cause is some networking code that knows a bit too much about its size & packing.

I am happy to troubleshoot, but I am no kernel expert. Tips would be appreciated. Like how to dump the sbk buffer in both cases..

Sincerely,

Gertjan
















__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
