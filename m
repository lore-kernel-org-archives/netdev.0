From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net] af_packet: block BH in prb_shutdown_retire_blk_timer()
Date: Fri, 29 Nov 2013 10:19:29 +0100
Message-ID: <52985C21.7040303@redhat.com>
References: <1385715203-14712-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jstancek@redhat.com,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab3K2JT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 04:19:58 -0500
In-Reply-To: <1385715203-14712-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2013 09:53 AM, Veaceslav Falico wrote:
> Currently we're using plain spin_lock() in prb_shutdown_retire_blk_timer(),
> however the timer might fire right in the middle and thus try to re-aquire
> the same spinlock, leaving us in a endless loop.
>
> To fix that, use the spin_lock_bh() to block it.
>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Daniel Borkmann <dborkman@redhat.com>
> CC: Willem de Bruijn <willemb@google.com>
> CC: Phil Sutter <phil@nwl.cc>
> CC: Eric Dumazet <edumazet@google.com>
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Tested-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation.")
Acked-by: Daniel Borkmann <dborkman@redhat.com>

Thanks everyone!
