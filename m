From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument
 to iptunnel_handle_offloads
Date: Mon, 11 Jan 2016 13:24:53 +0000
Message-ID: <5693AD25.4020904@solarflare.com>
References: <56901197.8040808@solarflare.com>
 <56901244.8060809@solarflare.com>
 <CAKgT0UdQzW2+n7S3YOhAJVZY-q5bjYaQB0jDn7AD3zp2ZrkGZg@mail.gmail.com>
 <CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
 <CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:60711 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760108AbcAKNZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 08:25:01 -0500
In-Reply-To: <CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/16 02:05, Alexander Duyck wrote:
> If we clear skb->encapsulation if we don't have CHECKSUM_PARTIAL set
> then we don't have the issue.  Really the addition of the line
> clearing skb->encapsulation should probably be added to the first
> patch so that we don't leave skb->encapsulation set when we aren't
> requesting offloads.
Next version of series will have (in this patch)
  if (skb->ip_summed != CHECKSUM_PARTIAL) {
    skb->ip_summed = CHECKSUM_NONE;
    skb->encapsulation = 0;
  }

Will that do, or does it need to be squeezed into an earlier patch in the series (which one?)

-ed
