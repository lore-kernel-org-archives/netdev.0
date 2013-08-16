From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [RFC net-next] ipip: Add room for custom tunnel header
Date: Fri, 16 Aug 2013 15:11:51 +0200
Message-ID: <CAKfDRXiGaELeKBYgYBqHcwqBW_m8SSHok_9SDoCN2AN+BtVNzw@mail.gmail.com>
References: <1375969927-22235-1-git-send-email-kristian.evensen@gmail.com>
	<1375977658.4004.106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:39761 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594Ab3HPNLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 09:11:51 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2221668pdj.8
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 06:11:51 -0700 (PDT)
In-Reply-To: <1375977658.4004.106.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thank you very much for your feedback and sorry for not replying
earlier. I modified the patch and implemented setting a custom header
length as a netlink message attribute instead
(http://patchwork.ozlabs.org/patch/266456/). It was initially rejected
on the basis that I needed to provide some use-cases, which I did, so
lets see what happens. However, your comments apply to both patches,
so it would be interesting to discuss this.

> What happens if hlen is bigger than available headroom ?
>
> hlen comes from userspace and there is no safety check, right ?

Based on my understanding of the code, hlen will not be bigger than
available headroom. dev->needed_headroom is set to the tunnel header
length in ip_tunnel_bind_dev(). hlen is only read when adding a new
link, so this assignment cannot be skipped. However, I see that a
check along the lines of "hlen > 0 && hlen < (ETH_DATA_LEN -
LL_MAX_HDR - sizeof(iphdr)" should be added.

One potential side-effect is that one can overflow the mtu by
providing a large hlen. Will that be considered a security risk or
misconfiguration? Since you have to have the same rights to create a
tunnel as to create a link, a similar behavior can be accomplished by
creating a new link with a large mtu.

> What guarantee do we have _something_ will fill the bytes ?
> (We do not want to leak prior content of those bytes to the wire)

In the current patch, none. I assumed this was ok as inserting the
custom header does not make sense without another module filling in
the content. I do agree though, a memset should be added to zero out
the custom header.

Thanks again,
Kristian
