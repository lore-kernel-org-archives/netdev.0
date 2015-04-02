From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 1 Apr 2015 17:06:54 -0700
Message-ID: <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35757 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbbDBAGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:06:55 -0400
Received: by ierf6 with SMTP id f6so56840426ier.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 17:06:54 -0700 (PDT)
In-Reply-To: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 8:07 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> From: "hannes@stressinduktion.org" <hannes@stressinduktion.org>
>
> We should not consult skb->sk for output decisions in xmit recursion
> levels > 0 in the stack. Otherwise local socket settings could influence
> the result of e.g. tunnel encapsulation process.
>
> ipv6 does not conform with this in three places:
>
> 1) ip6_fragment: we do consult ipv6_npinfo for frag_size
>
> 2) sk_mc_loop in ipv6 uses skb->sk and checks if we should
>    loop the packet back to the local socket
>
> 3) ip6_skb_dst_mtu could query the settings from the user socket and
>    force a wrong MTU
>
> Furthermore:
> In sk_mc_loop we could potentially land in WARN_ON(1) if we use a
> PF_PACKET socket ontop of an IPv6-backed vxlan device.
>
> Reuse xmit_recursion as we are currently only interested in protecting
> tunnel devices.
>

Shouldn't these skb's be orphaned for tunnel cases? Or we still have
to keep skb->sk for other valid use?
