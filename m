From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 19:43:11 -0800
Message-ID: <1488339791.9415.285.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
         <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
         <CALCETrXogADnqymxaoqt=F3rDMpOYQ0xy7audng=t-Rx1bxqbw@mail.gmail.com>
         <20170228.222845.1863678335516061180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, willemdebruijn.kernel@gmail.com,
        mtk.manpages@gmail.com, netdev@vger.kernel.org, willemb@google.com,
        linux-api@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36201 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdCADnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 22:43:14 -0500
In-Reply-To: <20170228.222845.1863678335516061180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 22:28 -0500, David Miller wrote:

> These device are already choking, because as I stated this can already
> be done via sendfile().
> 
> Networking card wise this isn't an issue, chips bring the entire packet
> into their FIFO, compute checksums on the fly mid-stream, and then write
> the 16-bit checksum field before starting to write the packet onto the
> wire.
> 
> I think this is completely a non-issue, and we thought about this right
> from the start when sendfile() support was added nearly two decades ago.
> If network cards from back then didn't crap out in this situation I
> think the ones out there now are probably ok.

Well, we had to fix one issue with GSO fall back about 4 years ago.

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=cef401de7be8c4e155c6746bfccf721a4fa5fab9

So extra scrutiny would be nice.

Zero copy is incredibly hard to get right.
