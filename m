From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Fri, 18 Dec 2015 10:41:58 +0000
Message-ID: <5673E2F6.2000209@solarflare.com>
References: <5672D466.6050900@solarflare.com>
 <CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:48007 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752611AbbLRKmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 05:42:10 -0500
In-Reply-To: <CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/12/15 18:06, Tom Herbert wrote:
> I'm not sure that we need bits in VXLAN or any other encapsulation. It
> should be sufficient in udp_set_csum that if we already have
> CHECKSUM_PARTIAL that can always be used to do local checksum offload.
My understandingis that otherwise iptunnel_handle_offloads() will do the
 inner checksum in sw, because csum_help will be passed as true.  It will
 call skb_checksum_help().
> This is also should be independent as to whether the device does
> NETIF_F_HW_CSUM or can offload  NETIF_F_IP[V6]_CSUM for encapsulated
> packets.
I was wary of drivers that declare NETIF_F_IP[V6]_CSUM but don't cope with
 encapsulated packets.  Would they do the right thing if the inner_csum bool
 in patch 2 just tested for NETIF_F_CSUM_MASK, or do I need to test things
 like NETIF_F_GSO_UDP_TUNNEL_CSUM?  I'm afraid I don't entirely understand
 the infrastructure here, so I just did the minimal thing I was sure worked,
 i.e. testing for NETIF_F_HW_CSUM.
> It would be nice to have a more formal documentation also. This is a
> very powerful mechanism but the math behind it and requirements are
> subtle.
>
> Tom
What would be a good place to put such documentation?  In
 Documentation/networking, or as part of the big checksums comment at the
 top of skbuff.h?

-ed
