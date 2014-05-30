From: Andy Lutomirski <luto@amacapital.net>
Subject: iproute2 bug: please specify a netlink destination
Date: Fri, 30 May 2014 11:36:04 -0700
Message-ID: <CALCETrUpynVUaWWOKf=ko3jYmTcTB9CH8tK0ton1uLuDvx1yzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:44664 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbaE3SgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 14:36:25 -0400
Received: by mail-ve0-f170.google.com with SMTP id db11so2584725veb.29
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 11:36:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

strace ip link says:

socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, 0) = 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=3853, groups=00000000}, [12]) = 0
sendto(3, "(\0\0\0\22\0\1\3\351\316\210S\0\0\0\0\21\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
40, 0, NULL, 0) = 40

The fact that sendto doesn't return -ENOTCONN is a straight up bug,
and, of course, it's now unfixable.  But please at least fix iproute2
to minimize future pain.

--Andy
