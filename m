From: Yotam Gigi <yotamg@mellanox.com>
Subject: ipmr: MFC routes when VIF deleted
Date: Sun, 11 Jun 2017 11:55:07 +0300
Message-ID: <67ef0899-928a-d2cb-bf12-4bea80240dbe@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Donald Sharp <sharpd@cumulusnetworks.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20079.outbound.protection.outlook.com ([40.107.2.79]:43232
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751764AbdFKIzP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Jun 2017 04:55:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been looking into some weird behavior, and I am not sure whether it is
a bug or a feature.

When a VIF with index v gets deleted, the MFC routes does not get updated, which
means that there can be routes pointing to that VIF. On datapath, when packet
hits that route, the VIF validity will be checked and will not be sent to that
device (but still, the route does not get updated).  Now, if the user creates
another VIF with the same index v but different underlay device, the same route
will forward the traffic to that device.

It is relevant to mention that when user adds a MFC route, only the active VIFs
are used, so the flow of adding a route with dummy VIF indices and then
connecting those VIF indices to real device is not supported. The only way to
create a MFC route that has non existing VIFs is to create one with existing
VIFs and then delete them.

Do we really want to support that?  To me, it looks like a buggy flow and I
suggest that upon VIF deletion, the MFC routes will be updated to not point to
any non existing VIF indices.
