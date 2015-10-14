From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH net-next 2/7] tcp: track min RTT using windowed min-filter
Date: Wed, 14 Oct 2015 06:25:48 -0700
Message-ID: <20151014132548.GA3960@mininet-vm>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
 <1445057867-32257-3-git-send-email-ycheng@google.com>
 <20151014092800.GA3748@mininet-vm>
 <CADVnQyk1e+csk_kX3D+E2CCeBi3sAKGjePEn3bAWceVFNf02Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37038 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbJSDJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 23:09:08 -0400
Received: by igbhv6 with SMTP id hv6so48349979igb.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 20:09:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CADVnQyk1e+csk_kX3D+E2CCeBi3sAKGjePEn3bAWceVFNf02Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 18, 2015 at 10:33:41AM -0400, Neal Cardwell wrote:
> On Wed, Oct 14, 2015 at 5:28 AM, Andrew Shewmaker <agshew@gmail.com> wrote:
> >> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >> index 38743e5..e177386 100644
> >> --- a/net/ipv4/tcp_input.c
> >> +++ b/net/ipv4/tcp_input.c
> > ...
> >> @@ -2961,7 +3028,7 @@ void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
> >>               rtt_us = skb_mstamp_us_delta(&now, &tcp_rsk(req)->snt_synack);
> >>       }
> >>
> >> -     tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L);
> >> +     tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L, rtt_us);
> >>  }
> >
> > This didn't apply to net-next for me. I see seq_rtt_us instead of
> > rtt_us and a check on the existence of tp->srtt_us. Maybe I've
> > misapplied the patch?
> 
> This patch series applies cleanly for me against David Miller's
> net-next at SHA1 4be3158 (from Friday Oct 16). (Using "git am" on the
> mbox patches from http://patchwork.ozlabs.org/project/netdev/list/
> ...)
> 
> On top of what SHA1 are you applying the series?

Doesn't matter which one ... it was the wrong one :)

I'd executed a git pull before applying the patch set, but I ended up having to
force it. Once I did, it applied cleanly.

Apologies for the false alarm,

Andrew
