From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: rxrpc: change call to
 sock_recv_ts_and_drops() on rxrpc recvmsg to sock_recv_timestamp()
Date: Thu, 26 Feb 2015 06:31:06 -0800
Message-ID: <1424961066.5565.151.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	 <1424916612-744-4-git-send-email-eyal.birger@gmail.com>
	 <1424925652.5565.145.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHsH6Gup09dtVZEi-vmp5ep_rs1ELueDudMJy1084e5vDbqJ0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45044 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932447AbbBZObJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:31:09 -0500
Received: by pdbnh10 with SMTP id nh10so13300122pdb.11
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:31:08 -0800 (PST)
In-Reply-To: <CAHsH6Gup09dtVZEi-vmp5ep_rs1ELueDudMJy1084e5vDbqJ0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 09:30 +0200, Eyal Birger wrote:

> Maybe I didn't understand your comment. Note this patch does not fix
> SO_RXQ_OVFL on rxrpc sockets.
> 
> I essentially reverted 3b885787ea4112 for these sockets.
> 
> It may be possible to compact rxrpc skb->cb[] usage by tricking the size
> of the resend_at variable as you suggested.
> 
> However, since SO_RXQ_OVFL never really worked on these sockets,
> I limited the patch series scope to moving skb->dropcount; This patch only
> signals that rxrpc can't support this feature unless some space is freed in its
> skb->cb[] use.
> --

My point is : If you stick this patch early in the serie, then skb->mark
will be overwritten by sock_recv_timestamp() (to store skb->dropcount)
and rxrpc breaks as it actively relies on skb->mark (apparently)

We dont care if SO_RXQ_OVFL is broken for rxprpc : Nobody noticed yet.

But breaking rxrpc skb->mark early in the serie does not help bisection
if needed later.
