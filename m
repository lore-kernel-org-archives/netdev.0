From: Florian Fainelli <f.fainelli@gmail.com>
Subject: multi-queue over IFF_NO_QUEUE "virtual" devices
Date: Mon, 7 Aug 2017 15:26:30 -0700
Message-ID: <21cdcfc2-0efc-c0df-6542-05bb8078d866@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org, jiri@resnulli.us, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37617 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdHGW0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 18:26:36 -0400
Received: by mail-wm0-f54.google.com with SMTP id t201so17293751wmt.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 15:26:36 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Most DSA supported Broadcom switches have multiple queues per ports
(usually 8) and each of these queues can be configured with different
pause, drop, hysteresis thresholds and so on in order to make use of the
switch's internal buffering scheme and have some queues achieve some
kind of lossless behavior (e.g: LAN to LAN traffic for Q7 has a higher
priority than LAN to WAN for Q0).

This is obviously very workload specific, so I'd want maximum
programmability as much as possible.

This brings me to a few questions:

1) If we have the DSA slave network devices currently flagged with
IFF_NO_QUEUE becoming multi-queue (on TX) aware such that an application
can control exactly which switch egress queue is used on a per-flow
basis, would that be a problem (this is the dynamic selection of the TX
queue)?

2) The conduit interface (CPU) port network interface has a congestion
control scheme which requires each of its TX queues (32 or 16) to be
statically mapped to each of the underlying switch port queues because
the congestion/ HW needs to inspect the queue depths of the switch to
accept/reject a packet at the CPU's TX ring level. Do we have a good way
with tc to map a virtual/stacked device's queue(s) on-top of its
physical/underlying device's queues (this is the static queue mapping
necessary for congestion to work)?

Let me know if you think this is the right approach or not.

Thanks!
-- 
Florian
