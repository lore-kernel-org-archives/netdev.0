From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: do not pace pure ack packets
Date: Sun, 15 Feb 2015 06:25:39 -0800
Message-ID: <1424010339.4942.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423017113.907.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMiB-qGF0C9tPEQHA5gqAF9JyMeOeSuUprb9N7HtVgRh1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	john fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:36896 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754941AbbBOOZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 09:25:42 -0500
Received: by mail-qc0-f171.google.com with SMTP id l6so20812991qcy.2
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 06:25:41 -0800 (PST)
In-Reply-To: <CAJ3xEMiB-qGF0C9tPEQHA5gqAF9JyMeOeSuUprb9N7HtVgRh1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-02-14 at 22:45 +0200, Or Gerlitz wrote:

> Wow, so what is the black box impact on systems running without the
> fix, pacing works but also un-needed slow downs
> are introduced, right?
> 
> Sounds to me as something we really want to push into -stable, isn't that?
> 
> Do you think we need to let the patch rot for a while in 3.20-rc or we
> can do it right away?

No impact at all. black box are forwarding packets, they are not pacing
them at all.

fq/pacing paces locally generated traffic only.

This works the following way :

TCP sets sk->sk_pacing_rate = 2 * cwnd * mss / srtt

fq then paces packets that are attached to a (local) socket, and where
sk->sk_pacing_rate is different than default value ( ~0U )

The only case a middle box could pace is when/if the optional 
'maxrate xxx' parameter is given to fq packet scheduler, and in this
case the intent is to have a max rate, including ACK packets.

I really do not think this patch is a stable candidate.

Thanks
