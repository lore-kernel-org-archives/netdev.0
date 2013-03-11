From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 2/2] tcp: TLP loss detection.
Date: Mon, 11 Mar 2013 17:38:12 -0400
Message-ID: <CADVnQy=qG1-qQCrF9VhZr8yj1wd-C0F6AO1zW9QAkro-EqW4hw@mail.gmail.com>
References: <1363032044-27315-1-git-send-email-nanditad@google.com>
	<1363032044-27315-2-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Ilpo Jarvinen <ilpo.jarvinen@cs.helsinki.fi>,
	Tom Herbert <therbert@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:33783 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab3CKViN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 17:38:13 -0400
Received: by mail-ee0-f52.google.com with SMTP id b15so2390711eek.39
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 14:38:12 -0700 (PDT)
In-Reply-To: <1363032044-27315-2-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 4:00 PM, Nandita Dukkipati <nanditad@google.com> wrote:
> This is the second of the TLP patch series; it augments the basic TLP
> algorithm with a loss detection scheme.
>
> This patch implements a mechanism for loss detection when a Tail
> loss probe retransmission plugs a hole thereby masking packet loss
> from the sender. The loss detection algorithm relies on counting
> TLP dupacks as outlined in Sec. 3 of:
> http://tools.ietf.org/html/draft-dukkipati-tcpm-tcp-loss-probe-01
>
> The basic idea is: Sender keeps track of TLP "episode" upon
> retransmission of a TLP packet. An episode ends when the sender receives
> an ACK above the SND.NXT (tracked by tlp_high_seq) at the time of the
> episode. We want to make sure that before the episode ends the sender
> receives a "TLP dupack", indicating that the TLP retransmission was
> unnecessary, so there was no loss/hole that needed plugging. If the
> sender gets no TLP dupack before the end of the episode, then it reduces
> ssthresh and the congestion window, because the TLP packet arriving at
> the receiver probably plugged a hole.
>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
