From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Thu, 7 Nov 2013 21:44:23 -0800
Message-ID: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:63886 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab3KHFoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 00:44:25 -0500
Received: by mail-wi0-f175.google.com with SMTP id hm2so420851wib.8
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 21:44:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 7, 2013 at 6:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While testing virtio_net and skb_segment() changes, Hannes reported
> that UFO was sending wrong frames.
>
> It appears this was introduced by a recent commit :
> 8c3a897bfab1 ("inet: restore gso for vxlan")
>
> The old condition to perform IP frag was :
>
> tunnel = !!skb->encapsulation;
> ...
>         if (!tunnel && proto == IPPROTO_UDP) {
>
> So the new one should be :
>
> udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
> ...
>         if (udpfrag) {
>
> Initialization of udpfrag must be done before call
> to ops->callbacks.gso_segment(skb, features), as
> skb_udp_tunnel_segment() clears skb->encapsulation
>
> (We want udpfrag to be true for UFO, false for VXLAN)
>
> With help from Alexei Starovoitov
>
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---

vxlan looks good through namespaces with and without gso
and between physical machines via 10G nics

Tested-by: Alexei Starovoitov <ast@plumgrid.com>

Thanks Eric!
