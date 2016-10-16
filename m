From: Isaac Boukris <iboukris@gmail.com>
Subject: iproute: ss truncates abstract unix domain socket embedding null
Date: Sun, 16 Oct 2016 23:43:13 +0300
Message-ID: <CAC-fF8SMUsj8pPJO+VYdRSQAOcwyBpJY1C9V3VEk3zrFS=Jy4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34412 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754399AbcJPUnQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 16:43:16 -0400
Received: by mail-lf0-f52.google.com with SMTP id b81so248258054lfe.1
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 13:43:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The unix(7) man page says that null have no special meaning in
abstract unix domain socket address (the length is specified
therefore).

However, when such name (embedding null) is used, ss (and netstat)
will only show up to the first null occurrence (second technically, if
we count the null prefix).
e.g. the name "\0/tmp/fo\0.sock" is displayed as: "@/tmp/fo" (whilst
strace tool shows it as: sun_path=@"/tmp/fo\0.sock").

Would it be more useful if it printed the whole name and escaped the null?
If so, would '\0' be ok for escaping the null?

Thanks!
