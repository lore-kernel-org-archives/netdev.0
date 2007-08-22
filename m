From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Oops in e100_up
Date: Wed, 22 Aug 2007 09:56:48 +0100
Message-ID: <200708220956.48297@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:65209 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762555AbXHVJCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 05:02:01 -0400
Received: from gerrit (gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id l7M8uBkb016737
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 09:56:11 +0100 (BST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the davem-2.6.24 tree I get the following Oops in the e100 driver (cribbed from console):

Code: 6c ff ff ff 8b 48 0c ba 01 00 00 00 89 f0 e8 1b f2 ff ff c7 86 9c 00 00 00
      01 00 00 00 e9 4e ff ff ff 89 d0 e8 b3 f8 0b 00 eb 8e <0f> 0b eb fe 55 89 e5
      56 53 83 ec 0c 8b 98 dc 01 00 00 e8 ff b9

EIP: e100_up+0x11d/0x121 

SS:ESP 0068:f759ce38

Stack: syscall_call -> sys_ioctl -> vfs_ioctl -> do_ioctl -> sock_ioctl -> inet_ioctl -> devinet_ioctl ->
       dev_change_flags -> dev_open -> e100_open -> oops

The system log then goes on reporting "eth0: link up, 100Mbps, full-duplex" and hangs while trying to
restore the serial console state (not sure that this is related).
