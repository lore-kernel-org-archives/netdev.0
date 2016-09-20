From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 05/10] bnxt_en: Fix ethtool -l|-L
 inconsistent channel counts.
Date: Tue, 20 Sep 2016 15:52:14 +0100
Message-ID: <20160920155214.3ea1e280@jkicinski-Precision-T1700>
References: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
        <1474354228-3221-6-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:32780 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcITOwV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:52:21 -0400
Received: by mail-lf0-f45.google.com with SMTP id h127so17179852lfh.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 07:52:20 -0700 (PDT)
In-Reply-To: <1474354228-3221-6-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, 20 Sep 2016 02:50:23 -0400, Michael Chan wrote:
> The existing code is inconsistent in reporting and accepting the combined
> channel count.  bnxt_get_channels() reports maximum combined as the
> maximum rx count.  bnxt_set_channels() accepts combined count that
> cannot be bigger than max rx or max tx.
> 
> For example, if max rx = 2 and max tx = 1, we report max supported
> combined to be 2.  But if the user tries to set combined to 2, it will
> fail because 2 is bigger than max tx which is 1.
> 
> Fix the code to be consistent.  Max allowed combined = max(max_rx, max_tx).
> We will accept a combined channel count <= max(max_rx, max_tx).
> 
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Sorry I wasn't able to respond in time but I'm with Yuval on this one.

The canonical meaning for the parameters is set by man page for ethtool:
>        rx N   Changes the number of channels with only receive queues.
> 
>        tx N   Changes the number of channels with only transmit queues.
> 
>        other N
>               Changes the number of channels used only for other purposes e.g.
>               link interrupts or SR-IOV co-ordination.
> 
>        combined N
>               Changes the number of multi-purpose channels.

Could we please agree that combined means having both RX and TX and the
others mean having only the specified one?  See for example:

e261768e9e39 ("be2net: support asymmetric rx/tx queue counts")
