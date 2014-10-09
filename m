From: michele.dionisio@gmail.com
Subject: [PATCH] ipv6: honour non local bind
Date: Thu,  9 Oct 2014 17:04:22 +0200
Message-ID: <1412867063-28433-1-git-send-email-michele.dionisio@gmail.com>
Cc: Michele Dionisio <michele.dionisio@gmail.com>
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36526 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757563AbaJIPEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 11:04:54 -0400
Received: by mail-wi0-f175.google.com with SMTP id d1so13469696wiv.8
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 08:04:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michele Dionisio <michele.dionisio@gmail.com>


Hi all,

I see that net.ipv4.ip_nonlocal_bind = 1 does not works on ipv6 if you try to bind on not local ip.
An easy test to see the issue using python is:

set  net.ipv4.ip_nonlocal_bind = 1 and in python shell try to execute

import socket
s = socket.socket(family=socket.AF_INET6)
s.bind(('2a01:84a0:1001:A001:0000:0:0015:8', 1234))

you receive an error. In ipv4 it works.

The patch attached solve the issue

Michele Dionisio (1):
  ipv6: make ipv6 bind honour non local bind as IPV4

 net/ipv6/af_inet6.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-- 
2.1.1
