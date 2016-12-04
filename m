From: Marco Zunino <eng.marco.zunino@gmail.com>
Subject: Trigger EHOSTUNREACH
Date: Sun, 4 Dec 2016 13:04:43 +0100
Message-ID: <CAP__gDkhM82EP6pP0NBHAYME0iPkEf49aeOp9C3dYQcCpdetrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36782 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbcLDMEq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 07:04:46 -0500
Received: by mail-wm0-f50.google.com with SMTP id g23so57747743wme.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 04:04:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo everyone, hope you are having a good day
we are building a networking testing tool to simulate network error
condition, and we are having difficulties triggering the EHOSTUNREACH
socket error.

We are trying to trigger this error by sending an ICMP packet type=3
code=3 on an open STREAM socket, but it has no effect.

Based on RFC1122 and the code here

https://github.com/torvalds/linux/blob/e76d21c40bd6c67fd4e2c1540d77e113df962b4d/net/ipv4/tcp_ipv4.c#L353

I would expect the this ICMP packet to abort the socket connection
with a EHOSTUNREACH error on the client side, but this does not
happen.

In RFC5927 we also see basically all hard_error should not be
considered so, and TCP connection never being aborted as a result of
ICMP error, for security and robustness reason.

If we send the same ICMP on a STREAM socket in SYN_SENT state (while
still waiting for the SYN_ACK to be received) the socket fails but
with an error ECONNREFUSED.

Could you give us a direction to better understand how ICMP errors
interact with TCP sockets? What about DGRAM sockets?

Thank you!

- Z
