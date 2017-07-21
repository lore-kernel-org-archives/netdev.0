From: Paul Moore <paul@paul-moore.com>
Subject: SELinux/IP_PASSSEC regression in 4.13-rcX
Date: Fri, 21 Jul 2017 18:19:06 -0400
Message-ID: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: selinux@tycho.nsa.gov
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:38183 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753502AbdGUWTI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 18:19:08 -0400
Received: by mail-lf0-f42.google.com with SMTP id y15so27877049lfd.5
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 15:19:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've been seeing a SELinux regression with IP_PASSSEC on the v4.13-rcX
kernels and finally tracked the problem down to the
skb_release_head_state() call in __udp_queue_rcv_skb().  Looking at
the code and the git log it would appear that the likely culprit is
0a463c78d25b ("udp: avoid a cache miss on dequeue
"); it looks similar to IP option problem fixed in 0ddf3fb2c43d2.

>From a SELinux/IP_PASSSEC point of view we need access to the skb->sp
pointer to examine the SAs.  I'm posting this here without a patch
because it isn't clear to me how you would like to fix the problem; my
initial thought would be to simply make the skb_release_head_state()
conditional on the skb->sp pointer, much like the IP options fix, but
I'm not sure if you have a more clever idea.

-- 
paul moore
www.paul-moore.com
