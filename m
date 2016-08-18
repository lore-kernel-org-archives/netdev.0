From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/3] Fix mv88e6xxx wait function
Date: Fri, 19 Aug 2016 00:01:54 +0200
Message-ID: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38659 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754024AbcHSBzL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6xxx wait function can be upset of the system has nots of
other things to do and a sleep takes a lot longer than expected. Fix
this be using a fixed number of iterations, rather than a fixed
walkclock time.

Witht that change made, it is possible to consoliate another
wait function.

A wait actually timing out should not happen and when it does, it
means something serious is wrong. Make sure an error is logged,
since not all callers will log an error.

Andrew Lunn (3):
  dsa: mv88e6xxx: Timeout based on iterations, not time
  dsa: mv88e6xxx: Use mv88e6xx_wait in mv88e6xxx_update()
  dsa: mv88e6xxx: Make mv88e6xxx_wait() timeout verbose

 drivers/net/dsa/mv88e6xxx/chip.c | 32 +++++++++++---------------------
 1 file changed, 11 insertions(+), 21 deletions(-)

-- 
2.8.1
