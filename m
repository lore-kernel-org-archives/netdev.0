From: Alexei Starovoitov <ast@plumgrid.com>
Subject: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 17:15:19 -0700
Message-ID: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:50810 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586AbaJWAPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 20:15:21 -0400
Received: by mail-wg0-f50.google.com with SMTP id a1so4850223wgh.21
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 17:15:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

in the commit 6f532612cc24 ("net: introduce netdev_alloc_frag()")
you mentioned that the reason to disable interrupts
in __netdev_alloc_frag() is:
"- Must be IRQ safe (non NAPI drivers can use it)"

Is there a way to do this conditionally?

Without it I see 10% performance gain for my RX tests
(from 6.9Mpps to 7.7Mpps) and __netdev_alloc_frag()
itself goes from 6.6% to 2.1%
(popf seems to be quite costly)

Thanks
Alexei
