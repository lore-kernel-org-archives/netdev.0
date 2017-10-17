From: Christoph Paasch <cpaasch@apple.com>
Subject: Re: [PATCH net-next] tcp: Enable TFO without a cookie on a per-socket
 basis
Date: Tue, 17 Oct 2017 09:49:50 -0700
Message-ID: <20171017164950.GH73751@Chimay.local>
References: <20171017063714.17346-1-cpaasch@apple.com>
 <CANn89i+50uOGyyNKd8HMsPuZpmxFpsj28gHc7LAV_0BL9NpkEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out5.apple.com ([17.151.62.27]:49027 "EHLO
        mail-in5.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932689AbdJQQto (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 12:49:44 -0400
Content-disposition: inline
In-reply-to: <CANn89i+50uOGyyNKd8HMsPuZpmxFpsj28gHc7LAV_0BL9NpkEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/10/17 - 04:00:01, Eric Dumazet wrote:
> On Mon, Oct 16, 2017 at 11:37 PM, Christoph Paasch <cpaasch@apple.com> wrote:
> > We already allow to enable TFO without a cookie by using the
> > fastopen-sysctl and setting it to TFO_SERVER_COOKIE_NOT_REQD (0x200).
> > This is safe to do in certain environments where we know that there
> > isn't a malicous host (aka., data-centers).
> >
> > A server however might be talking to both sides (public Internet and
> > data-center). So, this server would want to enable cookie-less TFO for
> > the connections that go to the data-center while enforcing cookies for
> > the traffic from the Internet.
> >
> > This patch exposes a socket-option to enable this (protected by
> > CAP_NET_ADMIN).
> 
> Have you thought instead of a route attribute ?

Another use-case for per-socket configuration is where the application-level
protocol already provides an authentication mechanism in the first flight of
data so that the cookie basically becomes redundant. In that case, it is
useful to configure it on a per-socket basis if other services are running
on this server as well.

I can of course add the route attribute in the v2, but I think the sockopt has
its use-case as well.

> CAP_NET_ADMIN restriction is not really practical IMO.

I'm fine with removing it.

I added it because an unpreviliged user could more easily mount an
amplification attack. But that is probably quite a stretch :)


Christoph
