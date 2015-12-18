From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Fri, 18 Dec 2015 11:41:34 -0800
Message-ID: <CALx6S35n+dt-F6m3TvW6KfbDq883Uzvi_unduDgPcT2H-Cf7ZQ@mail.gmail.com>
References: <5672D466.6050900@solarflare.com>
	<CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
	<5673E2F6.2000209@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:32955 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964776AbbLRTle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:41:34 -0500
Received: by mail-ig0-f180.google.com with SMTP id mv3so39825608igc.0
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 11:41:34 -0800 (PST)
In-Reply-To: <5673E2F6.2000209@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 2:41 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 17/12/15 18:06, Tom Herbert wrote:
>> I'm not sure that we need bits in VXLAN or any other encapsulation. It
>> should be sufficient in udp_set_csum that if we already have
>> CHECKSUM_PARTIAL that can always be used to do local checksum offload.
> My understandingis that otherwise iptunnel_handle_offloads() will do the
>  inner checksum in sw, because csum_help will be passed as true.  It will
>  call skb_checksum_help().
>> This is also should be independent as to whether the device does
>> NETIF_F_HW_CSUM or can offload  NETIF_F_IP[V6]_CSUM for encapsulated
>> packets.
> I was wary of drivers that declare NETIF_F_IP[V6]_CSUM but don't cope with
>  encapsulated packets.  Would they do the right thing if the inner_csum bool
>  in patch 2 just tested for NETIF_F_CSUM_MASK, or do I need to test things
>  like NETIF_F_GSO_UDP_TUNNEL_CSUM?  I'm afraid I don't entirely understand
>  the infrastructure here, so I just did the minimal thing I was sure worked,
>  i.e. testing for NETIF_F_HW_CSUM.

Drivers indicate that can do NETIF_F_IP[V6]_CSUM for encapsulation by
setting enc_features. This is checked in validate_xmit_skb so that if
drive can't handle encapsulated checksum skb_checksum_help is called
there.

 >> It would be nice to have a more formal documentation also. This is a
>> very powerful mechanism but the math behind it and requirements are
>> subtle.
>>
>> Tom
> What would be a good place to put such documentation?  In
>  Documentation/networking, or as part of the big checksums comment at the
>  top of skbuff.h?
>
I don't think this right for skbuff.h that should just describe the
interface. LCO has no interface like checksum-unnecessary conversion.
Checksumming, encapsulation, segmentation offloads are complex enough
now there should really be a Linux doc on this maybe modeled after
scaling.txt. That's probably more than you bargained for in this
patch, but if someone wants to learn how this infrastructure really
works, writing a doc is a good way! :-)

Tom
