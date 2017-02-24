From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/2] VXLAN/geneve RCU fixes
Date: Fri, 24 Feb 2017 11:43:35 -0800
Message-ID: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Pravin Shelar <pshelar@ovn.org>, Jiri Benc <jbenc@redhat.com>,
        "John W . Linville" <linville@tuxdriver.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33252 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdBXTw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:52:56 -0500
Received: by mail-pf0-f180.google.com with SMTP id o64so475589pfb.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 11:52:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

VXLAN and GENEVE need to take RCU lock explicitly because TX path
only has the _bh() flavour of RCU locked.  Making the reconfiguration
path wait for both normal and _bh() RCU would be bigger hassle so
just acquire the lock, as suggested by Pravin:

https://www.mail-archive.com/netdev@vger.kernel.org/msg155583.html

Jakub Kicinski (2):
  vxlan: lock RCU on TX path
  geneve: lock RCU on TX path

 drivers/net/geneve.c | 2 ++
 drivers/net/vxlan.c  | 8 ++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

-- 
2.11.0
