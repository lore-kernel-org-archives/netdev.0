From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.9] address family not supported for sendmsg()
Date: Fri, 22 Oct 2004 15:30:56 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022.153056.57690221.yoshfuji@linux-ipv6.org>
References: <21A5F45EFF209A44B3057E35CE1FE6E403981824-100000@eammlex037.lmc.ericsson.se>
	<20041021225820.72d278c7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: suresh.krishnan@ericsson.ca, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20041021225820.72d278c7.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041021225820.72d278c7.davem@davemloft.net> (at Thu, 21 Oct 2004 22:58:20 -0700), "David S. Miller" <davem@davemloft.net> says:

> On Fri, 22 Oct 2004 00:27:14 -0400 (EDT)
> Suresh Krishnan <suresh.krishnan@ericsson.ca> wrote:
> 
> > --- linux-2.6.9/net/ipv6/udp.c  2004-10-18 17:54:55.000000000 -0400
> > +++ linux-2.6.9-patched/net/ipv6/udp.c  2004-10-21 16:37:52.000000000 -0400
> > @@ -699,7 +699,7 @@
> >                 if (likely(up->pending)) {
> >                         if (unlikely(up->pending != AF_INET6)) {
> >                                 release_sock(sk);
> > -                               return -EINVAL;
> > +                               return -EAFNOSUPPORT;
> 
> I think this case should remain -EINVAL.

EAFNOSUPPORT may be okay.

If we try to push data for ipv6 socket
while data is pending for ipv4 destination,
the family of destination (ipv6) is not allowed for that socket.
This may be convered by EAFNOSUPPORT.

--yoshfuji
