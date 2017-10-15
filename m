From: Alexander Aring <aring@mojatatu.com>
Subject: routing UAPI mismatch invalid state behavior?
Date: Sun, 15 Oct 2017 13:02:20 -0400
Message-ID: <CAOHTApje2ABpRPghhqabD=JkBOzjFjVmc1N67ReDBLHeGGVe1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:43392 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdJORCW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 13:02:22 -0400
Received: by mail-ua0-f177.google.com with SMTP id u32so8264743uau.0
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 10:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I figure out some problem, easy to reproduce:

# setup dummy
$ modprobe dummy
$ ip link set dummy0 up

# issue
$ ip route replace default via 169.254.65.37 dev dummy0
RTNETLINK answers: Network is unreachable

so it will forbid me to do that, but:

$ ip route replace 169.254.65.37 dev dummy0
$ ip route replace default via 169.254.65.37 dev dummy0
$ ip route del 169.254.65.37 dev dummy0

allows me to do that. Is there now a invalid state in my routing table
or is it an expected behavior?

- Alex
