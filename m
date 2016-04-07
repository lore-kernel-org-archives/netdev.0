From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/2] fix two more udp pull header issues
Date: Thu,  7 Apr 2016 18:12:57 -0400
Message-ID: <1460067179-67789-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, tom@herbertland.com, samanthakumar@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35967 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757884AbcDGWNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:13:08 -0400
Received: by mail-qk0-f194.google.com with SMTP id e124so4287587qkc.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:13:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Follow up patches to the fixes to RxRPC and SunRPC. A scan of the
code showed two other interfaces that expect UDP packets to have
a udphdr when queued: read packet length with ioctl SIOCINQ and
receive payload checksum with socket option IP_CHECKSUM.

Willem de Bruijn (2):
  udp: do not expect udp headers on ioctl SIOCINQ
  udp: do not expect udp headers in recv cmsg IP_CMSG_CHECKSUM

 net/ipv4/ip_sockglue.c | 3 ++-
 net/ipv4/udp.c         | 4 +---
 2 files changed, 3 insertions(+), 4 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
