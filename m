From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v1=5D=20net=3A=20phy=3A=20fix=20auto-negotiation=20stall=20due=20to=20unavailable=20interrupt?=
Date: Thu, 20 Apr 2017 14:00:03 +0300
Message-ID: <1492686004-30527-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Alexander Kochetkov <al.kochet@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Roger Quadros <rogerq@ti.com>,
        Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36181 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754062AbdDTLAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 07:00:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian, Roger and Madalin!

This is slightly modified version of previous patch[1].

It take into account that phy_start_aneg() may be called from
differend places not only from PHY state machine. So the patch
use phy_trigger_machine() to schedule link state update
correctly.

I borrow some text from Roger's commit message.

Added 'Cc: stable <stable@vger.kernel.org> tag'
because the problem exist on 4.9 and 4.10 branches.

Don't know what commit brake the code, so I don't add
Fixes tag.

Roger, could you please test this one patch?

Madalin, I found, that you tested Roger’s patch[2] and this
one patch will get upstream instead of patch[2]. Could you
please test it?

Regards,
Alexander.

[1] http://patchwork.ozlabs.org/patch/743773/
[2] https://lkml.org/lkml/2017/3/30/517

Alexander Kochetkov (1):
  net: phy: fix auto-negotiation stall due to unavailable interrupt

 drivers/net/phy/phy.c |   40 ++++++++++++++++++++++++++++++++++++----
 include/linux/phy.h   |    1 +
 2 files changed, 37 insertions(+), 4 deletions(-)

-- 
1.7.9.5
