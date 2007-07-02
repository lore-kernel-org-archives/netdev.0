From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: sky2 silicon bugs and workarounds...
Date: Mon, 2 Jul 2007 14:37:06 +0100
Message-ID: <6278d2220707020637m2f11a691x9c51ca4bfe823104@mail.gmail.com>
References: <6278d2220707020636h7764fb27lb648ce50f1597b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:64588 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754847AbXGBNhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 09:37:08 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1256796ugf
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2007 06:37:06 -0700 (PDT)
In-Reply-To: <6278d2220707020636h7764fb27lb648ce50f1597b4@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

When the sky2 driver initialises, it sets the the ISR timer register
(STAT_ISR_TIMER_INI) to 125 * 20 = 2500, whereas the vendor sk98lin
driver sets it to 400, irrespective of the clockspeed of the NIC
processor.

I guess you found more performance/stability from this value...?

I've checked through the errata workarounds common to my rev-1 and 2
Yukon-EC chips...the HWF_WA_DEV_4167 "oversize receive hang"
workaround checks and can reset the (as I understand) bus master unit
of the NIC (in CheckRxPath) in a periodic timer that is fired, where
is finds no progress is made.

With the issues we see, can they be detected earlier by the stats
counters not being incremented, then resetting the bus-master unit,
rather than the whole chip getting kicked after a far longer period.

It looks like if it is a silicon bug, we can just acknowledge it and
have a better framework to detect the chip's PCI interface locking up
and kick it in a smarter way perhaps...

Daniel
--
Daniel J Blueman
