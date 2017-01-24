From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 09:42:07 -0800
Message-ID: <1485279727.16328.303.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
         <20170123185922.48046-4-tracywwnj@gmail.com>
         <20170124073043.GA21590@1wt.eu>
         <CAK6E8=eR5N-AV9sDJGwB-VKTojqSBRnPF6e7cK4jeavTzP97Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Wei Wang <tracywwnj@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35020 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750716AbdAXRmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:42:10 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so17177910pge.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 09:42:09 -0800 (PST)
In-Reply-To: <CAK6E8=eR5N-AV9sDJGwB-VKTojqSBRnPF6e7cK4jeavTzP97Hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 09:26 -0800, Yuchung Cheng wrote:

> >
> > Do you think there's a compelling reason for adding a new option or
> > are you interested in a small patch to perform the change above ?
> I like the proposal especially other stack also uses TCP_FASTOPEN
> https://msdn.microsoft.com/en-us/library/windows/desktop/ms738596(v=vs.85).aspx


Problem is that might break existing applications that were using
TCP_FASTOPEN before a connect() (it was a NOP until now)

I prefer we use a separate new option to be 100% safe, not adding
regressions.

Only new applications, tested, will use this new feature at their risk.
