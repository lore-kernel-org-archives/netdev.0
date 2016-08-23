From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v3 net-next] net: diag: support SOCK_DESTROY for UDP sockets
Date: Wed, 24 Aug 2016 02:24:39 +0900
Message-ID: <CAKD1Yr26iC-7DEtNHP4Rgig0uCNq9Rk6t4ASBX3D0tB=75SZ+w@mail.gmail.com>
References: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr19f3E-z4Lat-YDwJ7U7-fmVBeissz08dsk2o+196OQRQ@mail.gmail.com>
 <417574bb-d15d-f347-d951-49d0eede02c0@cumulusnetworks.com>
 <CAKD1Yr0FM9YKHFTYMeYipvyTWDLoM8EvcxVpcYwAWFHQZuS+6Q@mail.gmail.com> <e0d15dd5-28d1-6df5-c62c-1cc272a6a164@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37843 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753725AbcHWRZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 13:25:16 -0400
Received: by mail-it0-f54.google.com with SMTP id f6so146952060ith.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 10:25:00 -0700 (PDT)
In-Reply-To: <e0d15dd5-28d1-6df5-c62c-1cc272a6a164@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 2:16 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> So you'd remove the sock_put and sock_gen_put calls from tcp_abort and
>> just add one sock_gen_put in tcp_diag_destroy? That does seem simpler.
>
> untested and mangled on a copy and paste but the intent is:
...
>         if (IS_ERR(sk))
>                 return PTR_ERR(sk);
>
> -       return sock_diag_destroy(sk, ECONNABORTED);
> +       err = sock_diag_destroy(sk, ECONNABORTED);
> +
> +       sock_gen_put(sk);     <---- if (!sk_fullsock(sk)) needed here? seems like this works for all TCP

That does seem nicer. I think sock_gen_put will work on all types of
TCP sockets, so sk_fullsock is not needed here.

Eric, any thoughts?
