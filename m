From: chetan loke <loke.chetan@gmail.com>
Subject: Block based abstraction in af_packet->Rx::mmap
Date: Sun, 22 May 2011 13:46:40 -0400
Message-ID: <BANLkTi=wJ_4kabJjvgbJRAsPnbYEaA-tCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:49536 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036Ab1EVRql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 13:46:41 -0400
Received: by pxi16 with SMTP id 16so3456122pxi.4
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 10:46:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

With the current af_packet->rx::mmap based approach, the element size
in the block needs to be statically configured.
Nothing wrong with the current config/implementation. But since the
traffic profile cannot be known in advance, it would be nice if that
configuration
wasn't static. Normally, one would configure the element-size
to be '2048' so that you can atleast capture the entire 'MTU-size'.
But if the traffic profile varies then we would end up either
i)wasting memory or ii) end up getting a sliced frame.

In other words the packet density will be much much less in the first case.

Also, today we have to spin-wait/poll if a single packet is ready for
consumption(is status == TP_STATUS_USER?).
This does not scale. Rather, poll-waiting on a single block will
definitely help.

Q1)Is anyone working on enhancing the current mmap implementation?
Q2)Do patches exist for such non-static implementation already?


PS: Please CC me on the replies as I am not subscribed on the mailing list.


Regards
Chetan
