From: chetan loke <loke.chetan@gmail.com>
Subject: af-packet tpacket_rcv - why is status flushed before the
 packet-payload ...
Date: Fri, 24 Jun 2011 11:20:35 -0400
Message-ID: <BANLkTikjntd2Da_gScrpGb3n1-jzj+04Bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50433 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab1FXPUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 11:20:36 -0400
Received: by pzk9 with SMTP id 9so1836835pzk.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 08:20:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

in tpacket_rcv() - this is the flushing sequence ...

1)
__packet_set_status(po, h.raw, status);

2)
smp_mb();

3)
#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
flush-the-payload
#endif

Why is it done this way?

Shouldn't we be flushing the packet_status after flushing the payload?
So 1 and 3 should be swapped, no?

Chetan Loke
