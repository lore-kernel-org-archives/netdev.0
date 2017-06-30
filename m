From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 17:49:35 -0700
Message-ID: <CACby=pm5Qn4byjoDfCOo9Ty9AUpe4vzv66M=khExn7y9GdKMwg@mail.gmail.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
 <CACby=pnLJRawb40Ym1_85+8P7vmkwLJqfsv=bYyeHHa8KWPwNA@mail.gmail.com> <CALx6S37ZnymFfXWAV34iXbZd_XA3QeC+rQ+RnSVNi_Mg5eHhyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33276 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdF3Atl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 20:49:41 -0400
Received: by mail-pf0-f180.google.com with SMTP id e7so58486558pfk.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 17:49:41 -0700 (PDT)
In-Reply-To: <CALx6S37ZnymFfXWAV34iXbZd_XA3QeC+rQ+RnSVNi_Mg5eHhyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 June 2017 at 16:21, Tom Herbert <tom@herbertland.com> wrote:
> I think the main part of that discussion was around stream parser
> which is needed for message delineation. For a 1:1 proxy,  KCM is
> probably overkill (the whole KCM data path and lock becomes
> superfluous). Also, there's no concept of creating a whole message
> before routing it, in the 1:1 case we should let the message pass
> through once it's cleared by the filter (this is the strparser change
> I referred to). As I mentioned, for L7 load balancing we would want a
> multiplexor probably also M:N, but the structure is different since
> there's still no user facing sockets, they're all TCP for instance.
> IMO, the 1:1 proxy case is compelling to solve in itself...

I see. I was definitely thinking m:n. We should definitely evaluate
whether it makes sense to have a specific 1:1 implementation if we
need m:n anyway. For L7 LB, m:n seems obvious as a particular L4
connection may act as a transport for multiple requests bidirectional.
KCM looks like a good starting point for that.

When I talked about enqueueing entire messages, the main concern is to
buffer up the payload after the TLS handshake to the point to where a
forwarding decision can be made. I would definitely not advocate to
buffer entire messages before starting to forward.
