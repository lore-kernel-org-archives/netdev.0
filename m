From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Tue, 13 Oct 2015 11:22:23 +0200
Message-ID: <20151013092223.GE11304@distanz.ch>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
 <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com>
 <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <56180147.6070205@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:36453 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbbJMJbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 05:31:16 -0400
Content-Disposition: inline
In-Reply-To: <56180147.6070205@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-10-09 at 20:02:47 +0200, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/09/2015 12:50 PM, Eric Dumazet wrote:
> >On Thu, 2015-10-08 at 20:42 -0700, Tom Herbert wrote:
> >>On Thu, Oct 8, 2015 at 8:37 AM, Eric Dumazet <edumazet@google.com> wrote:
> >>>As promised in last patch series, we implement a better SO_REUSEPORT
> >>>strategy, based on cpu affinities if selected by the application.
> >>>
> >>>We also moved sk_refcnt out of the cache line containing the lookup
> >>>keys, as it was considerably slowing down smp operations because
> >>>of false sharing. This was simpler than converting listen sockets
> >>>to conventional RCU (to avoid sk_refcnt dirtying)
> >>>
> >>>Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.
> >>>
> >>Is this IPv4, IPv6, or some combination of the two ? :-)
> >
> >IPv4 only (mostly because I was using trafgen and its csumtcp() only
> >deals with IPv4 and I am lazy)
> 
> Agreed, will fix that in trafgen. ;) Thanks!

Daniel, I'd have som preliminary patches for trafgen ready to introduce
the csumudp6 and csumtcp6 trafgen helper functions (UDP/TCP checksum
using IPv6 pseudo headers). If you want I can push them after some
further testing later today.

Eric, would these to helpers be sufficient for your use case or do you
need any additional trafgen functionality?
