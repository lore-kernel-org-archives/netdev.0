From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Transmitting 802.1p frames without 802.1q?
Date: Wed, 12 Mar 2014 21:55:09 -0700
Message-ID: <CAGVrzcZuhOV4-z8uTsT38kWDq1kcAedV_3OvXn0xsiMydRJERA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: pedro.netdev@dondevamos.com, Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49677 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaCMEzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 00:55:51 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so560620pad.31
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 21:55:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pedro, Eric, Patrick,

Commit ad1afb003939 vlan_dev: VLAN 0 should be treated as "no vlan
tag" (802.1p packet) did allow receiving 802.1p frames without
necessarily creating a VLAN w/ VID0 interface.

After setting up a VLAN interface with VID0, the packets are properly
tagged while being transmitted, but this also required the receiver to
have a  VLAN interface with VID0, which does not seem like it should
be required thanks to the above commit.

Should we have a special set of SO_PRIORITY values which will
automatically insert a VLAN tag with ID0 and PCP fields (like what
net/wireless/util.c::cfg80211_classify8021d does)?

Thanks!
-- 
Florian
