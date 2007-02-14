From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: Problem with 2.6.20 and hostap_cs (Netgear MA401)
Date: Wed, 14 Feb 2007 10:50:40 -0800
Message-ID: <20070214105040.8a771551.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David G Hamblen <dhamblen@adelphia.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39113 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932424AbXBNSuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 13:50:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 14 Feb 2007 11:59:00 -0500
From: David G Hamblen <dhamblen@adelphia.net>
To: Kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Problem with 2.6.20 and hostap_cs (Netgear MA401)


I've got the ieee80211 and hostap code compiled as modules for my MA401 
card,  and the system locks up when I insert the card.  No keyboard, no 
sysrq, no logs after reboot, no nothing. The same configuration works 
fine under 2.6.19.

If I first insert my old 3com 3c589 card, then eject it and rmmod the 
3c589_cs module, the insertion of the MA401 works completely. Preloading 
the modules with insmod or modprobe doesn't help.

Was there a change in the pcmcia or networking initialization code 
between 2.6.19 and 2.6.20?

Here are the relevant modules.

#/sbin/lsmod
Module                  Size  Used by
ieee80211_crypt_wep     5248  0
hostap_cs              59220  3
hostap                110852  1 hostap_cs
ieee80211_crypt         5632  2 ieee80211_crypt_wep,hostap
...
pcmcia                 29280  1 hostap_cs
firmware_class          9664  1 pcmcia
yenta_socket           26892  4
...
rsrc_nonstatic         13248  1 yenta_socket
pcmcia_core            39056  4 \ 
hostap_cs,pcmcia,yenta_socket,rsrc_nonstatic

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
