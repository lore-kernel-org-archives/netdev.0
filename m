From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] anycast support for IPv6, linux-2.5.31
Date: Fri, 30 Aug 2002 09:37:38 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <25083.3144564696$1030689459@news.gmane.org>
References: <OFA5382C90.D39B906F-ON88256C23.00771A5C@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFA5382C90.D39B906F-ON88256C23.00771A5C@boulder.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 28 Aug 2002, David Stevens wrote:
> 1) The API
>       Although the RFC's liken anycasting to ordinary unicasting, I think
> it's more appropriate to tie it closely to particular applications, so I've
> chosen an API similar to multicasting. So, rather than having a permanent
> anycast address associated with the machine, particular applications
> that use anycasting can join or leave "anycast groups," and the machine will
> recognize the anycast addresses as its own when one or more applications have
> joined the group.
>       So, for example, someone using anycasting for DNS high availability
> can add a join to the anycast group in the server and as long as the DNS server
> is running, the machine will answer to that anycast address. But the machine
> will not respond to anycasts when the service that's using it isn't available,
> so a broken server application that has exited won't deny that service if
> there are other working members of the anycast group on other hosts.
>       I don't know if that's controversial or not-- the RFC's are written
> more from the external context, but seem to imply a model along the lines of
> using "ifconfig" to add anycast addresses. I think that model doesn't fit the
> best uses of anycasting, but I'd like to hear your thoughts on it.
>       The application interface for joining and leaving anycast groups is 2
> new setsockopt() calls: IPV6_JOIN_ANYCAST and IPV6_LEAVE_ANYCAST. The arguments
> are the same as the corresponding multicast operations. The kernel keeps a
> reference count of members; when that goes to zero, the anycast address is not
> recognized as a local address. While nonzero, the host listens on the solicited
> node for that address, sends advertisements in response to solicitations (with
> override=0) and delivers packets sent to the anycast address to upper layers.
>       There's also an in-kernel interface described below, which is used by
> IPv6 mobility, for example.

Before going too much down this path, I think one should write an Internet
Draft about the proposed API (should be quite short & simple) and see what
kind of response it has in the relevant working groups.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
