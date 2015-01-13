From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 13:36:53 +0100
Message-ID: <1421152613.13626.24.camel@redhat.com>
References: <54B4A7E4.7030301@gmail.com> <20150112231021.316648e3@urahara>
	 <1421145346.13626.12.camel@redhat.com> <54B50873.4090907@miraclelinux.com>
	 <54B50C71.7090007@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Ahern <dsahern@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbbAMMhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 07:37:03 -0500
In-Reply-To: <54B50C71.7090007@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Di, 2015-01-13 at 21:15 +0900, YOSHIFUJI Hideaki wrote:
> YOSHIFUJI Hideaki wrote:
> > Hi,
> >
> > Hannes Frederic Sowa wrote:
> >> On Mo, 2015-01-12 at 23:10 -0800, Stephen Hemminger wrote:
> >>> On Mon, 12 Jan 2015 22:06:44 -0700
> >>> David Ahern <dsahern@gmail.com> wrote:
> >>>
> >>>> We noticed that IPv6 addresses are removed on a link down. e.g.,
> >>>>     ip link set dev eth1
> >>>>
> >>>>
> >>>> Looking at the code it appears to be this code path in addrconf.c:
> >>>>
> >>>>           case NETDEV_DOWN:
> >>>>           case NETDEV_UNREGISTER:
> >>>>                   /*
> >>>>                    *      Remove all addresses from this interface.
> >>>>                    */
> >>>>                   addrconf_ifdown(dev, event != NETDEV_DOWN);
> >>>>                   break;
> >>>>
> >>>> IPv4 addresses are NOT removed on a link down. Is there a particular
> >>>> reason IPv6 addresses are?
> >>>>
> >>>> Thanks,
> >>>> David
> >>>
> >>> See RFC's which describes how IPv6 does Duplicate Address Detection.
> >>> Address is not valid when link is down, since DAD is not possible.
> >>
> >> It should be no problem if the kernel would reacquire them on ifup and
> >> do proper DAD. We simply must not use them while the interface is dead
> >> (also making sure they don't get used for loopback routing).
> >>
> >> The problem the IPv6 addresses get removed is much more a historical
> >> artifact nowadays, I think. It is part of user space API and scripts
> >> deal with that already.
> >
> > We might have another "detached" state which essintially drops
> > outgoing packets while link is down.  Just after recovering link,
> > we could start receiving packet from the link and perform optimistic
> > DAD. And then, after it succeeds, we may start sending packets.
> >
> > Since "detached" state is like the state just before completing
> > Optimistic DAD, it is not so difficult to implement this extended
> > behavior, I guess.
> >
> 
> Note that node is allowed to send packets to neighbours or default
> routers if the node knows their link-layer addresses during Optimistic
> DAD.
> 

I don't think it should be a problem from internal state handling of the
addresses.

I am much more concerned with scripts expecting the addresses to be
flushed on interface down/up and not reacting appropriate.

Bye,
Hannes
