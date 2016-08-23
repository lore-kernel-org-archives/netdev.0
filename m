From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v3 net-next] net: diag: support SOCK_DESTROY for UDP sockets
Date: Wed, 24 Aug 2016 02:13:31 +0900
Message-ID: <CAKD1Yr0FM9YKHFTYMeYipvyTWDLoM8EvcxVpcYwAWFHQZuS+6Q@mail.gmail.com>
References: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr19f3E-z4Lat-YDwJ7U7-fmVBeissz08dsk2o+196OQRQ@mail.gmail.com> <417574bb-d15d-f347-d951-49d0eede02c0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38136 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbcHWRUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 13:20:54 -0400
Received: by mail-it0-f54.google.com with SMTP id n128so147500766ith.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 10:20:54 -0700 (PDT)
In-Reply-To: <417574bb-d15d-f347-d951-49d0eede02c0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 2:02 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> Looking at the code again, it seems that there's a bug in
>> sock_diag_destroy. If the destroy operation does not occur (e.g., if
>> sock_diag_destroy returns EPERM, or the protocol doesn't support
>> destroy), then it doesn't release the refcount. This affects the TCP
>> code as well and as such is my fault, not yours. The most obvious way
>> to fix this might be to call sock_gen_put in sock_diag_destroy.
>
> sock_gen_put seems specific to tcp which is why I used sock_put here.

I thought sock_gen_put can be used on UDP as well, but it does seem a
bit counterintuitive.

> Perhaps better to have the callers of sock_diag_destroy handle the refcnt? This
> function took it; it should release it success or fail. Same for tcp.

So you'd remove the sock_put and sock_gen_put calls from tcp_abort and
just add one sock_gen_put in tcp_diag_destroy? That does seem simpler.
