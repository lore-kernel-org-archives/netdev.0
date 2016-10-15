From: Pascal Terjan <pterjan@gmail.com>
Subject: linux/atm_zatm.h not really usable in userspace since cf00713a655d3019be7faa184402f16c43a0fed3
Date: Sat, 15 Oct 2016 13:05:10 +0100
Message-ID: <CA+CX+bjErkFu=VVv55PtiWg-Z88twBUyE20vo5A3fk9=ZD_LLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34580 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcJOMF1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 08:05:27 -0400
Received: by mail-wm0-f45.google.com with SMTP id c78so3743984wme.1
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 05:05:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is no longer possible to include <linux/atm_zatm.h> + userspace
headers using time, for example  <stdlib.h>, this broke for example
the build of linux-atm.

Reproducer:

$ cat test.c
#include <linux/atm_zatm.h>
#include <stdlib.h>

$ gcc -c test.c
In file included from /usr/include/sys/select.h:43:0,
                 from /usr/include/sys/types.h:219,
                 from /usr/include/stdlib.h:314,
                 from test.c:2:
/usr/include/time.h:120:8: error: redefinition of 'struct timespec'
 struct timespec
        ^
In file included from /usr/include/linux/atm_zatm.h:17:0,
                 from test.c:1:
/usr/include/linux/time.h:9:8: note: originally defined here
 struct timespec {
        ^
In file included from /usr/include/sys/select.h:45:0,
                 from /usr/include/sys/types.h:219,
                 from /usr/include/stdlib.h:314,
                 from test.c:2:
/usr/include/bits/time.h:30:8: error: redefinition of 'struct timeval'
 struct timeval
        ^
In file included from /usr/include/linux/atm_zatm.h:17:0,
                 from test.c:1:
/usr/include/linux/time.h:15:8: note: originally defined here
 struct timeval {
        ^
