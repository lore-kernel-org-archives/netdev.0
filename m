From: Dominic Curran <dominic.curran@citrix.com>
Subject: igb: question regarding auto-negotiation
Date: Fri, 29 Jul 2016 16:37:39 -0700
Message-ID: <579BE8C3.806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12064 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbcG2Xh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 19:37:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This question refers to igb codebase.
I have a question regarding the setting of hw->mac.autoneg.

Is it correct to say for igb driver:
    "if speed=1000 and duplex=FULL and media_type=COPPER  then  only 
auto-negotiate enable is supported"

i.e.
    with these settings (speed/duplex/media_type) then auto-negotiate 
can _not_ be disabled.  Correct ?

I say this for two reasons:
1) The code in igb_set_spd_dplx() seems to indicate it:

        case SPEED_1000 + DUPLEX_FULL:
                 mac->autoneg = 1;
                 adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
                 break;

2) Instrumenting the driver, I always see the autoneg code in 
e1000_check_for_copper_link_generic()  get called after an igb_reset().


Have i understood correctly ?

thanks in advance
dom
