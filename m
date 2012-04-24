From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Tue, 24 Apr 2012 22:10:28 +0200
Message-ID: <1335298228.5205.168.camel@edumazet-glaptop>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36111 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757466Ab2DXUKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 16:10:38 -0400
Received: by wgbdr13 with SMTP id dr13so1042436wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 13:10:35 -0700 (PDT)
In-Reply-To: <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 12:49 -0700, Maciej =C5=BBenczykowski wrote:
> Why do we refuse to set ipv6 mtu's below 1280?
> how is what we do any better?

I guess you didnt read Tore use case.

Thats the standard : http://tools.ietf.org/html/rfc2460#section-5

   In response to an IPv6 packet that is sent to an IPv4 destination
   (i.e., a packet that undergoes translation from IPv6 to IPv4), the
   originating IPv6 node may receive an ICMP Packet Too Big message
   reporting a Next-Hop MTU less than 1280.  In that case, the IPv6 nod=
e
   is not required to reduce the size of subsequent packets to less tha=
n
   1280, but must include a Fragment header in those packets so that th=
e
   IPv6-to-IPv4 translating router can obtain a suitable Identification
   value to use in resulting IPv4 fragments.  Note that this means the
   payload may have to be reduced to 1232 octets (1280 minus 40 for the
   IPv6 header and 8 for the Fragment header), and smaller still if
   additional extension headers are used.
