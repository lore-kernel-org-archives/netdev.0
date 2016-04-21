From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Thu, 21 Apr 2016 09:02:48 -0700
Message-ID: <CAKgT0Uc-MfZseKauJMW+xh+5LTEww6hcWmuXeCATsDA+Z-POsQ@mail.gmail.com>
References: <20160421074042.GF3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34055 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596AbcDUQCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 12:02:49 -0400
Received: by mail-io0-f176.google.com with SMTP id 2so90785738ioy.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 09:02:49 -0700 (PDT)
In-Reply-To: <20160421074042.GF3347@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 12:40 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> This partly reverts the below mentioned patch because on
> forwarding, such skbs can't be offloaded to a NIC.
>
> We need this to get IPsec GRO for forwarding to work properly,
> otherwise the GRO aggregated packets get segmented again by
> the GSO layer. Although discovered when implementing IPsec GRO,
> this is a general problem in the forwarding path.

I'm confused as to why you would need this to get IPsec GRO forwarding
to work.  Are you having to go through a device that doesn't have
NETIF_F_FRAGLIST defined?  Also what is the issue with having to go
through the GSO layer on segmentation?  It seems like we might be able
to do something like what we did with GSO partial to split frames so
that they are in chunks that wouldn't require NETIF_F_FRAGLIST.  Then
you could get the best of both worlds in that the stack would only
process one super-frame, and the transmitter could TSO a series of
frames that are some fixed MSS in size.

- Alex
