From: =?UTF-8?Q?Mantas_Mikul=c4=97nas?= <grawity@gmail.com>
Subject: regression (4.10) - interface remove uevents not generated
Date: Sat, 11 Mar 2017 17:10:22 +0200
Message-ID: <d519f10b-8512-efa2-03a1-81f6e4a91c7c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35519 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdCKPKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 10:10:31 -0500
Received: by mail-lf0-f66.google.com with SMTP id v2so8806049lfi.2
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 07:10:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It seems that commit 002d8a1a6c11b9b2a8ac615095589111dd52749b ("net:
skip genenerating uevents for network namespaces that are exiting")
broke 'remove' uevents for *all* network interfaces, even for those in
the main/default namespace.

Other than breaking some of my udev rules, this also causes problems for
NetworkManager, which apparently relies on those uevents to update its
interface information cache. (I ended up reverting that commit locally
just so I could connect to VPNs again.)

This problem is present in both v4.10.1 and current master
(v4.11-rc1-290-g434fd6353b4c).

-- 
Mantas Mikulėnas <grawity@gmail.com>
