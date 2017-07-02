From: Leon Yang <leon.gh.yang@gmail.com>
Subject: Way to Know When cleanup_net() Calls Are Done
Date: Sun, 2 Jul 2017 00:50:08 -0500
Message-ID: <CAHvAHW8aq0Tb0tnNjQAySyDe_pwxHk2-+EHr_yPavuz_aKqAyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36336 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdGBFuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2017 01:50:10 -0400
Received: by mail-lf0-f54.google.com with SMTP id h22so87804284lfk.3
        for <netdev@vger.kernel.org>; Sat, 01 Jul 2017 22:50:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am measuring the time cost of parallel creation and destruction of
net namespaces.

As cleanup_net() is invoked from workqueue, the exit of a net
namespace does not mean the cleanup is completed. Therefore I use
ftrace to count the number of net_drop_ns() are called. But I found
that the number of namespaces created does not match with the number
of net_drop_ns() calls even after a long wait.

Can you give some hints on why this is happening? and what would be
the correct way to know when the last cleanup_net() is done?

Thanks,

Leon

*psudo code of my program:

n = 0;
while (1) {
        pid = fork();
        if (pid == 0) {
                unshare(CLONE_NEWNET);
                exit(0);
        } else if (/* run out of PID */) {
                /* wait for all the children */
                /* get total time for n creations+destructions */
                n = 0;
        } else { /* do nothing */ }
        n++;
}
