From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 10:07:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819100712.2470d18d.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5B@post.pc.aspectgroup.co.uk>
	<20030819095105.2cb9acc1.davem@redhat.com>
	<20030819191010.43d83b79.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: richard@aspectgroup.co.uk, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephan von Krawczynski <skraw@ithnet.com>
In-Reply-To: <20030819191010.43d83b79.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 19:10:10 +0200
Stephan von Krawczynski <skraw@ithnet.com> wrote:

> Well, then you have a problem, at least with RFC-985 as quoted in my other
> email.

RFC-985 does not take into consideration a system model where IP
addresses are owned by the host not specific interfaces which is a
valid system model that the RFC standards allow.

> <quote RFC-985>
> An ARP request is discarded if the source IP address is not in the same subnet.
> </quote>

This RFC is broken in an environment consistent of systems using
the host address ownership model.

It also doesn't consider cases where the host receiving the
ARP request is not aware of all subnets present on a LAN.

Ignoring such ARPs is therefore broken and prevents valid
communications from occuring.

Some systems implement this check to provide "pseudo security",
but it isn't even that.
