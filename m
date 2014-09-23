From: Willem de Bruijn <willemb@google.com>
Subject: Re: LTP recv/recvmsg tests failing on 3.17
Date: Tue, 23 Sep 2014 12:24:57 -0400
Message-ID: <CA+FuTSeyzMayJ6zR8KBpt_Wu-orCowMDtTOwXxp84-RobBZ1xA@mail.gmail.com>
References: <20140923091108.2788de76@as> <CA+FuTScNSGYxWtB-D_iL_7TQO=z4r5_29-W8d=VRwh1M6Ym_UQ@mail.gmail.com>
 <20140923103933.1b5fb88b@as>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:52298 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753708AbaIWQZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:25:29 -0400
Received: by mail-qa0-f44.google.com with SMTP id x12so1940698qac.3
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 09:25:29 -0700 (PDT)
In-Reply-To: <20140923103933.1b5fb88b@as>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But I was also wondering why we return EAGAIN here for no data waiting,
> when we return EINVAL for the same case with a different type of data.
> There's no spec and it's not documented, so I guess the answer is "it's
> always been that way."

EAGAIN is the common response. I don't know why TCP urgent
data returns EINVAL. It is unusual enough that the relevant line
in tcp_recv_urg explicitly comments on it:

                return -EINVAL; /* Yes this is right ! */
