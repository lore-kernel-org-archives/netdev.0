From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 2/2] inet: Fix get port to handle zero port
 number with soreuseport set
Date: Thu, 15 Dec 2016 10:58:29 -0500
Message-ID: <CAEfhGixrj8Ftwo8=F617o-ArwgCD+JmVUeJpNbU7xpydp=pjBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
        Josef Bacik <jbacik@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:33505 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752964AbcLOP6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 10:58:33 -0500
Received: by mail-wj0-f196.google.com with SMTP id kp2so10484590wjc.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 07:58:32 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by smtp.gmail.com with ESMTPSA id p144sm3006927wme.23.2016.12.15.07.58.30
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 07:58:31 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id a197so170461028wmd.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 07:58:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 7:54 PM, Tom Herbert <tom@herbertland.com> wrote:
> A user may call listen with binding an explicit port with the intent
> that the kernel will assign an available port to the socket. In this
> case inet_csk_get_port does a port scan. For such sockets, the user may
> also set soreuseport with the intent a creating more sockets for the
> port that is selected. The problem is that the initial socket being
> opened could inadvertently choose an existing and unreleated port
> number that was already created with soreuseport.
Good catch!  I think this problem may also exist in the UDP path?
(udp_lib_get_port -> udp_lib_lport_inuse[2])
