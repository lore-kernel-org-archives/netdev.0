From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 3/3] tcp: early retransmit: delayed fast retransmit
Date: Wed, 2 May 2012 15:34:41 -0400
Message-ID: <CADVnQyn6K8xH=wwi7pN0wsKS4wEhksi2pB0KbTaSDqLGWmnBaw@mail.gmail.com>
References: <1335984391-31340-1-git-send-email-ycheng@google.com>
	<1335984391-31340-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34049 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755897Ab2EBTem convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 15:34:42 -0400
Received: by ghrr11 with SMTP id r11so1068316ghr.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 12:34:41 -0700 (PDT)
In-Reply-To: <1335984391-31340-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 2:46 PM, Yuchung Cheng <ycheng@google.com> wrote=
:
> Implementing the advanced early retransmit (sysctl_tcp_early_retrans=3D=
=3D2).
> Delays the fast retransmit by an interval of RTT/4. We borrow the
> RTO timer to implement the delay. If we receive another ACK or send
> a new packet, the timer is cancelled and restored to original RTO
> value offset by time elapsed. =A0When the delayed-ER timer fires,
> we enter fast recovery and perform fast retransmit.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog in v2:
> =A0- Set sysctl_tcp_early_retrans default to 2
> ChangeLog in v3:
> =A0- use separate u8 for early retrans stats in tcp_sock
> =A0- disable ER if detects any reordering

After reading patch 3 of the series, I see that patch 3 incorporates
most of those suggestions from Monday. I think it would be quite a bit
cleaner to just have patch 2 of the series put the
tcp_disable_early_retrans() call and tcp_sock fields in the ultimately
desired place, rather than having patch 2 put them somewhere and patch
3 move them, but maybe that's just me.

When all the patches in the series are applied, the one issue I still
see is that frto_counter is in a new place, a bit further away from
frto_highmark than it used to be before the patch series. I think it
would be good  to keep frto_counter in its original location, back up
nearer to frto_highmark.

neal
