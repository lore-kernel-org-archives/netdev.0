From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Wed, 25 Jan 2017 11:03:02 -0800
Message-ID: <1485370982.5145.54.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170124191127.GG21921@1wt.eu>
         <CAC15z3izWNh7th_yxA_a90vgLnU5XzVDm6vyojq3cMDgQZ71YA@mail.gmail.com>
         <20170125.122205.9460825196595773.davem@davemloft.net>
         <20170125175458.GF23545@1wt.eu>
         <CAC15z3hG36VcanxLXtvxP-ta=Srom8P6E5Rds+jGjJ8vLj7TeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33955 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbdAYTDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:03:06 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so14924918pfb.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 11:03:06 -0800 (PST)
In-Reply-To: <CAC15z3hG36VcanxLXtvxP-ta=Srom8P6E5Rds+jGjJ8vLj7TeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 10:54 -0800, Wei Wang wrote:
> > Yes sorry David, for me it's OK. If Wei runs his whole series of tests
> > on it again, it should be perfect.
> 
> I just ran all the TFO related tests with Willy's patch on top of this
> patch series.
> And everything passes.

Note that I am not sure we correctly test that a second connect() can be
done, and I am not sure kernel would check that the remote IP and
destination port is the same.

Ie what should happen for

setsockopt(fd, SOL_TCP, TCP_FASTOPEN_CONNECT, &on, 4)
connect(fd,  "1.2.3.4:80")
connect(fd, "55.66.77.88:4000")

This multiple connect() thing should have been forbidden in the first
place really.
