From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Mon, 19 Dec 2016 18:41:42 -0800
Message-ID: <1482201702.1521.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481928610.17731.0@smtp.office365.com>
         <e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
         <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com>
         <20161219.205646.1955469060856026212.davem@davemloft.net>
         <CALx6S340vCsaymbx+CcKL3Zi2p9EvDSwc0fDAxKsSqs4C2p5kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Josef Bacik <jbacik@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36492 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751432AbcLTClp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 21:41:45 -0500
Received: by mail-io0-f195.google.com with SMTP id b194so21082716ioa.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 18:41:45 -0800 (PST)
In-Reply-To: <CALx6S340vCsaymbx+CcKL3Zi2p9EvDSwc0fDAxKsSqs4C2p5kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-19 at 18:07 -0800, Tom Herbert wrote:

> When sockets created SO_REUSEPORT move to TW state they are placed
> back on the the tb->owners. fastreuse port is no longer set so we have
> to walk potential long list of sockets in tb->owners to open a new
> listener socket. I imagine this is happens when we try to open a new
> listener SO_REUSEPORT after the system has been running a while and so
> we hit the long tb->owners list.

Hmm...  __inet_twsk_hashdance() does not change tb->fastreuse

So where tb->fastreuse is cleared ?

If all your sockets have SO_REUSEPORT set, this should not happen.
