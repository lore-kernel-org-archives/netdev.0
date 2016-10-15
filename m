From: Pascal Terjan <pterjan@gmail.com>
Subject: userspace build broken by include changes
Date: Sat, 15 Oct 2016 12:40:43 +0100
Message-ID: <CA+CX+bgbJ=aw7155Z_BbL4FpBVgu6RL4d2jR4dj2FNubj-v1BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34990 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbcJOLlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 07:41:00 -0400
Received: by mail-wm0-f41.google.com with SMTP id c78so27048385wme.0
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 04:40:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rp-pppoe plugin of ppp no longer builds:

In file included from pppoe.h:87:0,
                 from plugin.c:29:
/usr/include/linux/in.h:28:3: error: redeclaration of enumerator 'IPPROTO_IP'
   IPPROTO_IP = 0,  /* Dummy protocol for TCP  */
   ^
/usr/include/netinet/in.h:42:5: note: previous definition of
'IPPROTO_IP' was here
     IPPROTO_IP = 0,    /* Dummy protocol for TCP.  */

Short reproducer:

#include <sys/cdefs.h>
#include <sys/socket.h>
#include <linux/if.h>
#include <netinet/in.h>
#include <linux/ppp_defs.h>
#include <linux/if_pppox.h>

Full log:
http://pkgsubmit.mageia.org/autobuild/cauldron/x86_64/core/2016-10-12/ppp-2.4.7-8.mga6.src.rpm/build.0.20161012185227.log

Moving the include of linux/if.h after netinet/in.h fixes it.

I guess the breakage is caused by
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/include/uapi/linux?id=eafe92114308acf14e45c6c3d154a5dad5523d1a
but the commit doesn't look wrong to me.

This is indeed enough to cause the error:

#include <linux/if.h>
#include <netinet/in.h>
#include <linux/in.h>
