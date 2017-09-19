From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Reporting transceiver with ethtool_link_ksettings
Date: Tue, 19 Sep 2017 15:03:28 -0700
Message-ID: <8ff54ee0-0196-075f-207c-81bb8625fb3b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org, davem@davemloft.net,
        linville@tuxdriver.com, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:50802 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdISWDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:03:32 -0400
Received: by mail-qt0-f171.google.com with SMTP id f15so1094161qtf.7
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 15:03:32 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After tracking down why all network interfaces using PHYLIB and using
phy_ethtool_link_ksettings_get would report "Transceiver: internal" it
became clear that's because ethtool_link_ksettings deprecated that field...

We could have deprecated setting the transceiver which makes sense, but
not deprecating getting the transceiver type which is useful information.

So what are the options here? Would this be acceptable:

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 06fc04c73079..bb9b55806bf4 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1752,7 +1752,9 @@ struct ethtool_link_settings {
        __u8    eth_tp_mdix;
        __u8    eth_tp_mdix_ctrl;
        __s8    link_mode_masks_nwords;
-       __u32   reserved[8];
+       __u8    transceiver;
+       __u8    reserved1[3];
+       __u32   reserved[7];
        __u32   link_mode_masks[0];
        /* layout of link_mode_masks fields:
         * __u32 map_supported[link_mode_masks_nwords];
