From: Andy Johnson <johnsonzjo@gmail.com>
Subject: NETDEV_FEAT_CHANGE and ethtool (question)
Date: Sun, 12 May 2013 12:21:45 +0300
Message-ID: <CAF0Lin3mWT_GybiXE1AihZj8iRfmQ7ahNg51SHn6BKtbitFm4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:40736 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab3ELJVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 05:21:47 -0400
Received: by mail-wi0-f178.google.com with SMTP id hm14so1932273wib.17
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 02:21:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The only thing that netdev_features_change() does is send
NETDEV_FEAT_CHANGE event
notification.

NETDEV_FEAT_CHANGE event is sent in the core from
netdev_update_features() if __netdev_update_features returned 1, and
this event is *always* sent from netdev_change_features().

ethtool calls __netdev_update_features() when chaning features. So
changing GSO offload features for example, by
"ethtool -K gso off" will *not* trigger NETDEV_FEAT_CHANGE event notification.
(assuming that ndo_fix_features/ndo_set_features callbacks of the
driver, if exist, will not
trigger such noticiation call).

My question is: why changing features by ethtool does not trigger
sending NETDEV_FEAT_CHANGE event?


Best,
Andy
