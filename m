From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] tcp: do not pace pure ack packets
Date: Sat, 14 Feb 2015 22:45:18 +0200
Message-ID: <CAJ3xEMiB-qGF0C9tPEQHA5gqAF9JyMeOeSuUprb9N7HtVgRh1g@mail.gmail.com>
References: <1423017113.907.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	john fastabend <john.fastabend@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:35941 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbbBNUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 15:45:18 -0500
Received: by mail-ob0-f171.google.com with SMTP id gq1so31102462obb.2
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 12:45:18 -0800 (PST)
In-Reply-To: <1423017113.907.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 4:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When we added pacing to TCP, we decided to let sch_fq take care
> of actual pacing.
>
> All TCP had to do was to compute sk->pacing_rate using simple formula:
>
> sk->pacing_rate = 2 * cwnd * mss / rtt
>
> It works well for senders (bulk flows), but not very well for receivers
> or even RPC :
>
> cwnd on the receiver can be less than 10, rtt can be around 100ms, so we
> can end up pacing ACK packets, slowing down the sender.
> Really, only the sender should pace, according to its own logic.

[...]

> This patch is a combination of two patches we used for about one year at Google.

Wow, so what is the black box impact on systems running without the
fix, pacing works but also un-needed slow downs
are introduced, right?

Sounds to me as something we really want to push into -stable, isn't that?

Do you think we need to let the patch rot for a while in 3.20-rc or we
can do it right away?

Or
