From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: switchdev offload & ecmp
Date: Mon, 15 May 2017 16:25:43 +0200
Message-ID: <84b9801f-0c2a-cd55-61a4-411261943024@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37118 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933222AbdEOOZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:25:46 -0400
Received: by mail-wm0-f45.google.com with SMTP id d127so78450548wmf.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 07:25:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri and Ido,

I'm trying to understand how ecmp offloading works. It seems that rocker doesn't
support it:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/rocker/rocker_ofdpa.c#n2409.
But I saw that the support was added in spectrum:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?h=684a95c064fc.

Is there a consistency between the ecmp algorithm of the kernel and the one from
spectrum?
I suspect that there can be scenarii where some packets of a flow are forwarded
by the driver and some other are forwarded by the kernel.
For example, an ecmp route with two nexthops: a connected route and a gw? In
that case, the periodic nexthops update
(https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n987)
won't help. How do you ensure that all packets of the flow are always forwarded
through the same nexthop?


Regards,
Nicolas
