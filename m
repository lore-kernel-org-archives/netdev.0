From: Niklas Cassel <niklas.cassel@axis.com>
Subject: phy deadlock -stable backport request
Date: Mon, 27 Feb 2017 14:56:31 +0100
Message-ID: <b985983c-f649-a880-8d8f-734a64e1a673@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:49140 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdB0OTZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 09:19:25 -0500
Received: from localhost (localhost [127.0.0.1])
        by bastet.se.axis.com (Postfix) with ESMTP id 841C5182B2
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:56:33 +0100 (CET)
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
        by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id 3Br2RAPr9Xfo for <netdev@vger.kernel.org>;
        Mon, 27 Feb 2017 14:56:32 +0100 (CET)
Received: from boulder02.se.axis.com (boulder02.se.axis.com [10.0.8.16])
        by bastet.se.axis.com (Postfix) with ESMTPS id AE206180CE
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:56:32 +0100 (CET)
Received: from boulder02.se.axis.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 9EB6E1A08C
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:56:32 +0100 (CET)
Received: from boulder02.se.axis.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 940011A088
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:56:32 +0100 (CET)
Received: from thoth.se.axis.com (unknown [10.0.2.173])
        by boulder02.se.axis.com (Postfix) with ESMTP
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:56:32 +0100 (CET)
Received: from XBOX02.axis.com (xbox02.axis.com [10.0.5.16])
        by thoth.se.axis.com (Postfix) with ESMTP id 88A602CB
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:56:32 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I would like to request that

commit eab127717a6af54401ba534790c793ec143cd1fc
Author: Florian Fainelli <f.fainelli@gmail.com>
Date:   Fri Jan 20 15:31:52 2017 -0800

    net: phy: Avoid deadlock during phy_error()
   
    phy_error() is called in the PHY state machine workqueue context, and
    calls phy_trigger_machine() which does a cancel_delayed_work_sync() of
    the workqueue we execute from, causing a deadlock situation.
   
    Augment phy_trigger_machine() machine with a sync boolean indicating
    whether we should use cancel_*_sync() or just cancel_*_work().
   
    Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
    Reported-by: Russell King <rmk+kernel@armlinux.org.uk>
    Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

 drivers/net/phy/phy.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)


would be backported to stable branch v4.9.

I've seen this deadlock happen on v4.9.x


Regards,
Niklas
