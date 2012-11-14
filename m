From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 00/13] Always build GSO/GRO functionality into the
 kernel
Date: Tue, 13 Nov 2012 18:25:28 -0800
Message-ID: <1352859928.4497.1.camel@edumazet-glaptop>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60251 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375Ab2KNCZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 21:25:31 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so29900pbc.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 18:25:30 -0800 (PST)
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 20:24 -0500, Vlad Yasevich wrote:
> This patch series is a revision suggested by Eric to solve the problem where
> a host without IPv6 support drops GSO frames from the guest.
> 
> The problem is that GSO/GRO support is per protocol, and when said protocol
> is not loaded or is disabled, packets attempting to go through GSO/GRO code paths
> are dropped.  This causes retransmissions and a two orders of magnitude drop in
> performance.
> 
> Prior attempt to solve the problem simply enabled enough GSO/GRO functionality
> for IPv6 protocol when IPv6 was diabled.  This did not solve the problem when
> the protocol was not build in or was blacklisted.
> To solve the problem, it was suggested that we separate GSO/GRO callback
> registration from packet processing registrations.  That way
> GSO/GRO callbacks can be built into the kernel and always be there.
> This patch series attempts to do just that.
> * Patches 1 and 2 split the GSO/GRO handlers from packet_type and convert
>   to the new structure.
> * Patches 3, 4 and 5 do the same thing for net_protocol structure.
> * The rest of the patches try to incrementally move the IPv6 GSO/GRO
>   code out of the module and into the static kernel build.  Some IPv6
>   helper functions also had to move as well.
> 
> I am currently testing the patches, but if folks could look this over
> and send me any comments, I'd appreciate it.

Seems very nice !

I am just wondering if GSO/GRO is fully enabled at every step ?
