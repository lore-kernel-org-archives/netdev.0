From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH net-next 1/7] tcp: apply Kern's check on RTTs used for
 congestion control
Date: Tue, 2 Feb 2016 20:30:27 +0100
Message-ID: <CA++eYdtOmvKi8h=GZ3TGC_gQXHfK6r4YgsvYWhY5geM5XY3fzA@mail.gmail.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
	<1445057867-32257-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:35252 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656AbcBBTa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:30:28 -0500
Received: by mail-lb0-f194.google.com with SMTP id dx9so7115687lbc.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 11:30:27 -0800 (PST)
In-Reply-To: <1445057867-32257-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 17, 2015 at 6:57 AM, Yuchung Cheng <ycheng@google.com> wrote:
> Currently ca_seq_rtt_us does not use Kern's check. Fix that by
> checking if any packet acked is a retransmit, for both RTT used
> for RTT estimation and congestion control.
>
*snip*

This patch (commit 9e45a3e) puzzles me, because Karn's check was
already in effect:
http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c?v=4.3#L3117

Since first_ackt/last_ackt is only set when non-retransmitted packets
are ACKed (sequentially), we know them to be unambiguous samples for
RTTM. Even if a (sequential) ACK covers retransmitted packets, we can
still make a valid RTTM if that ACK also covers non-retransmitted
packets. But this patch seems to prevent that?
