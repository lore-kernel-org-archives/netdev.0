From: Matthew Daley <mattjd@gmail.com>
Subject: x25: Fix multiple buffer overruns/overreads
Date: Sat, 15 Oct 2011 00:45:02 -0400
Message-ID: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64092 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1JOEpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 00:45:02 -0400
Received: by iaek3 with SMTP id k3so3418201iae.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 21:45:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes several buffer overruns/overreads in the X.25
packet layer. The first patch fixes a particularly nasty remote-triggerable
buffer overflow, while the rest fix skb overreads on undersized/fragmented
skbs.

Matthew Daley (3):
      x25: Validate incoming call user data lengths
      x25: Handle undersized/fragmented skbs
      x25: Prevent skb overreads when checking call user data

 net/x25/af_x25.c         |   40 ++++++++++++++++++++++++++++++++--------
 net/x25/x25_dev.c        |    6 ++++++
 net/x25/x25_facilities.c |   10 ++++++----
 net/x25/x25_in.c         |   43 ++++++++++++++++++++++++++++++++++++++-----
 net/x25/x25_link.c       |    3 +++
 net/x25/x25_subr.c       |   14 +++++++++++++-
 6 files changed, 98 insertions(+), 18 deletions(-)
