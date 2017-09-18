From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: cross namespace interface notification for tun devices
Date: Mon, 18 Sep 2017 20:47:10 +0200
Message-ID: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mathias <mathias@hall-andersen.dk>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40375 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752156AbdIRSxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 18 Sep 2017 14:53:53 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id feac0868
        for <netdev@vger.kernel.org>;
        Mon, 18 Sep 2017 18:39:14 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 9a614d83 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Mon, 18 Sep 2017 18:39:13 +0000 (UTC)
Received: by mail-io0-f170.google.com with SMTP id e189so4510198ioa.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 11:47:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey guys,

It's possible to create a tun device in a process in namespace A and
then move that interface to namespace B. The controlling process in A
needs to receive notifications on when the interface is brought up or
down. It can receive these notifications via netlink while the
interface lives in A but not when it moves to B.

Any tricks or APIs to get around this?

The best I've come up with is, in a sleep loop, writing to the tun
device's fd something with a NULL or invalid payload. If the interface
is down, the kernel returns -EIO. If the interface is up, the kernel
returns -EFAULT. This seems to be a reliable distinguisher, but is a
pretty insane way of doing it. And sleep loops are somewhat different
from events too.

If there aren't any current APIs for receiving events directly from
the fd of a tun interface, would this list be happy with a patch that
adds one?

Thanks,
Jason
