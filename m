From: Tom Herbert <therbert@google.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 16:25:53 -0700
Message-ID: <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
References: <53ECFDAB.5010701@intel.com>
	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<53ED4354.9090904@intel.com>
	<20140814.162024.2218312002979492106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:40401 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbaHNXZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:25:54 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so433589igb.15
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:25:54 -0700 (PDT)
In-Reply-To: <20140814.162024.2218312002979492106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 4:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 14 Aug 2014 16:16:36 -0700
>
>> Are you sure about each socket having it's own DST?  Everything I see
>> seems to indicate it is somehow associated with IP.
>
> Right it should be, unless you have exception entries created by path
> MTU or redirects.
>
> WRT prequeue, it does the right thing for dumb apps that block in
> receive.  But because it causes the packet to cross domains as it
> does, we can't do a lot of tricks which we normally can do, and that's
> why the refcounting on the dst is there now.
>
> Perhaps we can find a clever way to elide that refcount, who knows.

I don't know if it's the same problem, but I did post a patch back in
January that would resolve false sharing of dst->__refcnt and rt_genid
in the same cacheline. We could revisit that if it helps.

Tom

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
