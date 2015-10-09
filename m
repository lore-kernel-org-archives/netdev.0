From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Fri, 09 Oct 2015 03:50:45 -0700
Message-ID: <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tobias Klauser <tklauser@distanz.ch>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35295 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbbJIKur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 06:50:47 -0400
Received: by pabve7 with SMTP id ve7so25409418pab.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 03:50:47 -0700 (PDT)
In-Reply-To: <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 20:42 -0700, Tom Herbert wrote:
> On Thu, Oct 8, 2015 at 8:37 AM, Eric Dumazet <edumazet@google.com> wrote:
> > As promised in last patch series, we implement a better SO_REUSEPORT
> > strategy, based on cpu affinities if selected by the application.
> >
> > We also moved sk_refcnt out of the cache line containing the lookup
> > keys, as it was considerably slowing down smp operations because
> > of false sharing. This was simpler than converting listen sockets
> > to conventional RCU (to avoid sk_refcnt dirtying)
> >
> > Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.
> >
> Is this IPv4, IPv6, or some combination of the two ? :-)

IPv4 only (mostly because I was using trafgen and its csumtcp() only
deals with IPv4 and I am lazy)

I guess IPv6 one might hit some issues before reaching TCP stack, I do
not see anything performance related in TCP itself.
