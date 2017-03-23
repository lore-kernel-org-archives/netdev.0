From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] net: bridge: allow user-space to add ext learned entries
Date: Thu, 23 Mar 2017 12:27:11 +0200
Message-ID: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: idosch@mellanox.com, jiri@resnulli.us, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:33246 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754642AbdCWK27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 06:28:59 -0400
Received: by mail-wr0-f181.google.com with SMTP id y90so26500675wrb.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 03:28:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This set adds the ability to add externally learned entries from
user-space. For symmetry and proper function we need to allow SW entries
to take over HW learned ones (similar to how HW can take over SW entries
currently) which is needed for our use case (evpn) where we have pure SW
ports and HW ports mixed in a single bridge. This does not play well with
switchdev devices currently because there's no feedback when the entry is
taken over, but this case has never worked anyway and feedback can be
easily added when needed.
Patch 02 simply allows to use NTF_EXT_LEARNED from user-space, we already
have Quagga patches that make use of this functionality.

Thanks,
 Nik

Nikolay Aleksandrov (2):
  net: bridge: allow SW learn to take over HW fdb entries
  net: bridge: allow to add externally learned entries from user-space

 net/bridge/br_fdb.c | 5 +++++
 1 file changed, 5 insertions(+)

-- 
2.1.4
