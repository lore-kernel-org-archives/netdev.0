From: jason.morgan@aveillant.com
Subject: tx checksum offload in rtl8168evl disabled in driver
Date: Thu, 3 Oct 2013 15:27:51 +0100
Message-ID: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-240.asp.reflexion.net ([69.84.129.240]:34548 "EHLO
	asp.reflexion.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753397Ab3JCO1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 10:27:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm try to get close to saturating a 1G ethernet.

I'm at 517Mbps and I've found that there seems to be a cpu bottleneck.

I'm using 2k to 4k frames with a rtl8168evl.

I notice from ethtool that tx-checksum is turned off and refuse to turn 
on.

I've found this message
http://www.spinics.net/lists/netdev/msg216530.html

Which indicates the cause being the driver.

I've looked at the driver code rtl8169.c in kernel 3.8 and the line 

        [RTL_GIGA_MAC_VER_34] =
                _R("RTL8168evl/8111evl",RTL_TD_1, FIRMWARE_8168E_3,
                                                        JUMBO_9K, false),

indicates the reason for this.

However the message thread, above indicates that this is not a problem and 

can be changed to make tx-checksum offload possible.

However we are using a newer chip to the on in the message thread.  I've 
tried to find other, more recent citations without success.

So, why is it still turned off?

What will be the effect of turning it on (changing false to true, in the 
driver line) for our chip?

Thanks in advance,
Jason
