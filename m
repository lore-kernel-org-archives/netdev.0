From: Frans Pop <elendil@planet.nl>
Subject: e1000e: Silly repetition of PCI name in log message
Date: Mon, 18 Aug 2008 12:19:39 +0200
Message-ID: <200808181219.39921.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml13.kpnxchange.com ([213.75.38.113]:1950 "EHLO
	hpsmtp-eml13.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751483AbYHRKfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 06:35:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With 2.6.27-rc3 I noticed the following messages in my boot log:
0000:01:00.0: 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:04:ff:09

The second seems correct, but the first has a silly repetition of the PCI 
device before the actual message. The message originates from 
e1000_eeprom_checks in e1000e/netdev.c.
Is this because e_warn in (which calls e_printk from e1000e/e1000.h) is 
used before adapter->netdev->name has been properly set? Looks likely as 
the eeprom checks are done some time before the device is registered.

Other question is why this is a "Warning"? Isn't "Deep Smart Power Down" a 
desirable feature to have?

Cheers,
FJP
