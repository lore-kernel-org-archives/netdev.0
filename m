From: David Held <drheld@google.com>
Subject: [PATCH net-next v2 0/2] udp: Fix multicast performance issues.
Date: Tue, 15 Jul 2014 17:22:41 -0400
Message-ID: <1405459363-3047-1-git-send-email-drheld@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:47038 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaGOVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 17:22:48 -0400
Received: by mail-oa0-f74.google.com with SMTP id eb12so356oac.1
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 14:22:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix performance issues with listening to many different multicast
sockets on different addresses with the same port. Instead of always
using hash1, fall back to hash2 lookup when hash1 lookup is long.
Patch 1 is a general cleanup and simplification which also makes the
main implementation in Patch 2 simpler.

Eric's recent change 63c6f81cdde5 avoided this being an issue in early
demux. This makes it work for regular delivery as well.
