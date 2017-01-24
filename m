From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 19:43:45 +0100
Message-ID: <20170124184345.GF21921@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170124073043.GA21590@1wt.eu>
 <CAK6E8=eR5N-AV9sDJGwB-VKTojqSBRnPF6e7cK4jeavTzP97Hw@mail.gmail.com>
 <1485279727.16328.303.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>, Wei Wang <tracywwnj@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:65023 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751045AbdAXSnw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 13:43:52 -0500
Content-Disposition: inline
In-Reply-To: <1485279727.16328.303.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 09:42:07AM -0800, Eric Dumazet wrote:
> On Tue, 2017-01-24 at 09:26 -0800, Yuchung Cheng wrote:
> 
> > >
> > > Do you think there's a compelling reason for adding a new option or
> > > are you interested in a small patch to perform the change above ?
> > I like the proposal especially other stack also uses TCP_FASTOPEN
> > https://msdn.microsoft.com/en-us/library/windows/desktop/ms738596(v=vs.85).aspx
> 
> 
> Problem is that might break existing applications that were using
> TCP_FASTOPEN before a connect() (it was a NOP until now)
> 
> I prefer we use a separate new option to be 100% safe, not adding
> regressions.
> 
> Only new applications, tested, will use this new feature at their risk.

That's indeed a good point. I Yuchung's comment above made me wonder
about application's portability but very few OSes will use this and in
the end it might be that portable applications will just add :

   #define TCP_FASTOPEN_CONNECT TCP_FASTOPEN

For other OSes and use TCP_FASTOPEN_CONNECT only for the connect() case.

Willy
