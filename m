From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: Fix netpoll interoperability
Date: Tue, 14 Apr 2015 07:52:20 -0700
Message-ID: <1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, bind@enas.net,
	peter@hurleysoftware.com, Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34969 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbbDNOwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 10:52:22 -0400
Received: by iejt8 with SMTP id t8so16718154iej.2
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 07:52:21 -0700 (PDT)
In-Reply-To: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 16:35 +0300, Yuval Mintz wrote:
> Commit 9a2620c877454 ("bnx2x: prevent WARN during driver unload") switched
> the napi/busy_lock locking mechanism from spin_lock() into spin_lock_bh(),
> breaking inter-operability with netconsole, as netpoll disables interrupts
> prior to calling our napi mechanism.
> 
> This switches the driver into using atomic assignments instead of the spinlock
> mechanisms previously employed.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> ---

This fix is prone to starvation of softirq handler.

Since you use 2 bits, I believe you could set one bit unconditionally to
make sure the bnx2x_low_latency_recv() will yield to softirq handler.

Please CC me and Willem on busypoll stuff, thanks !
