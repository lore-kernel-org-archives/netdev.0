From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: net: rps: support 802.1Q
Date: Fri, 19 Aug 2011 23:05:18 +0800
Message-ID: <CABa6K_FhG9_XrCfhJDhhUArFEeG5FqOoU_HN1vY-TOKmjMxBKQ@mail.gmail.com>
References: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com> <1313754853.2814.8.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:65174 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab1HSPFj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 11:05:39 -0400
Received: by ewy4 with SMTP id 4so1156913ewy.19
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 08:05:38 -0700 (PDT)
In-Reply-To: <1313754853.2814.8.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 7:54 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> Should this really be reading an unlimited number of tags?

Not unlimited, but it won't stop until reaching the end of the packet.

> =A0What if an
> attacker starts sending packets full of VLAN tags? =A0Since this runs
> before netfilter, there would be no way to prevent those packets burn=
ing
> our CPU time. =A0And if there are legitimately multiple VLAN tags, th=
ey
> presumably won't all have the 802.1q Ethertype.
>

Do we need to limit the number of rounds to stop this kind of "bad"
packets from burning our CPU time? Then,  __netif_receive_skb() has to
be update too, so the inspection of tunnel in __skb_get_rxhash() does.
Is there a such limitation in xfrm?

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
