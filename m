From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH v2 net] udpv6: reset daddr and dport in sk if connect() fails
Date: Thu, 22 Jun 2017 12:21:11 -0700
Message-ID: <CAHo-OozNvQc0mboSnvQL6NjSJHTEu4ca2SYCPrtGL9+5djh+fw@mail.gmail.com>
References: <20170622190341.87998-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34053 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753761AbdFVTVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 15:21:13 -0400
Received: by mail-yw0-f171.google.com with SMTP id e142so9714828ywa.1
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 12:21:12 -0700 (PDT)
In-Reply-To: <20170622190341.87998-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So this is clearly an improvement over the current state of things.

However, I think there is still a very slight race condition in the
error case, since I imagine udp early demux might find the socket
while ip6_datagram_dst_update() is running.

It's possible that inet_dport assignment could simply be postponed
until after the ip6_datagram_dst_update() call.

Another possibility would be to make the early demux code only capable
of finding TCP_ESTABLISHED sockets.

That said, I'm not sure what the right call would be.
