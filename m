From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 01 Apr 2015 17:27:38 -0700
Message-ID: <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
	 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34212 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbDBA1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:27:42 -0400
Received: by pactp5 with SMTP id tp5so67150536pac.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 17:27:42 -0700 (PDT)
In-Reply-To: <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-01 at 17:06 -0700, Cong Wang wrote:

> Shouldn't these skb's be orphaned for tunnel cases? Or we still have
> to keep skb->sk for other valid use?

skb should not be orphaned, until the very last stage.

Many layers depend on this, really.

Simply ask the question to yourself :

What if I do not associate skb to a socket at first. What possibly
breaks ?

orphaning skb just because they traverse a tunnel would be quite
horrible.
