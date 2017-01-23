From: Oleg Nesterov <oleg@redhat.com>
Subject: wrong smp_mb__after_atomic() in tcp_check_space() ?
Date: Mon, 23 Jan 2017 15:30:25 +0100
Message-ID: <20170123143025.GA31676@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert.xu@redhat.com>,
        Yauheni Kaliuta <yauheni.kaliuta@redhat.com>,
        netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49258 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750723AbdAWOa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 09:30:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

smp_mb__after_atomic() looks wrong and misleading, sock_reset_flag() does the
non-atomic __clear_bit() and thus it can not guarantee test_bit(SOCK_NOSPACE)
(non-atomic too) won't be reordered.

It was added by 3c7151275c0c9a "tcp: add memory barriers to write space paths"
and the patch looks correct in that we need the barriers in tcp_check_space()
and tcp_poll() in theory, so it seems tcp_check_space() needs smp_mb() ?

Oleg.
