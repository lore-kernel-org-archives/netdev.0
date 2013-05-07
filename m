From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Tue, 7 May 2013 12:59:53 -0400
Message-ID: <CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:62405 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab3EGQ7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 12:59:54 -0400
Received: by mail-lb0-f181.google.com with SMTP id w10so982638lbi.12
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 09:59:53 -0700 (PDT)
In-Reply-To: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 3, 2013 at 8:57 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
> Jakub reported that it is fairly easy to trigger the BUG() macro
> from user space with TPACKET_V3's RX_RING by just giving a wrong
> header status flag. We already had a similar situation in commit
> 7f5c3e3a80e6654 (``af_packet: remove BUG statement in
> tpacket_destruct_skb'') where this was the case in the TX_RING
> side that could be triggered from user space. So really, don't use
> BUG() or BUG_ON() unless there's really no way out, and i.e.
> don't use it for consistency checking when there's user space
> involved, no excuses, especially not if you're slapping the user
> with WARN + dump_stack + BUG all at once. The two functions are

remember, you were able to figure out what the problem was because of
the WARN and the forceful BUG.
Is BUG ok? Depends on how you look at it. If you are doing serious
network monitoring on a real life appliance
we don't really want folks to write crappy application. May be BUG is
too harsh. But then I don't see a WARN in this patch either (may be I
overlooked it).


> of concern:
>
>   prb_retire_current_block() [when block status != TP_STATUS_KERNEL]
>   prb_open_block() [when block_status != TP_STATUS_KERN

>
> Calls to prb_open_block() are guarded by ealier checks if block_status
> is really TP_STATUS_KERNEL (racy!), but the first one BUG() is easily
> triggable from user space. System behaves still stable after they are
> removed. Also remove that yoda condition entirely, since it's already
> guarded.

What yoda? It's called defensive programming. It's a single check and
not going to cost you anything.
