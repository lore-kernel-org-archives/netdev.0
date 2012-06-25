From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH RFC 0/8] LLDP implementation for Linux
Date: Mon, 25 Jun 2012 20:28:12 +0200
Message-ID: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:57839 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147Ab2FYS22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:28 -0400
Received: by ghrr11 with SMTP id r11so3094761ghr.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This series of patches provides a partial LLDP (IEEE Std 802.1ab)
implementation.

I'd really appreciate a review of it.

LLDP is a simple discovery protocol which advertises the identification and
other info (such as MTU or capabilities) of device on the link. It can also
help debug misconfigurations on the link layer (wrong MTU, wrong VLAN).

Some notes/questions:

* Applies against net-next and mainline.

* Included in this series is only LLDP output code.
  This is not an issue since input and output are decoupled in LLDP anyway.
  I'm working on the input code as well and will post it at some point in the
  future.

* Sysctl is used to do (some) configuration. This is done globally right now.
  Before I add per-device sysctls: is it at all appropriate to use sysctl
  here?

* By default, transmission is suppressed. To arm it, set
	/proc/sys/net/lldp/lldp_op_mode
  to 1.

* I've tested it on x86_64 and (qemu'd) x86.

* I've tested it on my machine and it works with Ethernet and WLAN.

* The last patch ("8021q/vlan: process NETDEV_GOING_DOWN") is needed
  to be able to send shutdown PDU on VLAN interfaces, but has otherwise
  no effect.

* Is there a better way to deal with 16-bit endianness other than masking and
  shifting, when one field is more than a byte long (in this case 7/9)?

* I usually only work on it on weekends, so I might be slow in responding back.

Thanks in advance if you're taking the time to review it or test it!

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
