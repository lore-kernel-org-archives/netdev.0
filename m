From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 11:35:46 +0100
Message-ID: <1421145346.13626.12.camel@redhat.com>
References: <54B4A7E4.7030301@gmail.com> <20150112231021.316648e3@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55188 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbbAMKf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 05:35:56 -0500
In-Reply-To: <20150112231021.316648e3@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2015-01-12 at 23:10 -0800, Stephen Hemminger wrote:
> On Mon, 12 Jan 2015 22:06:44 -0700
> David Ahern <dsahern@gmail.com> wrote:
> 
> > We noticed that IPv6 addresses are removed on a link down. e.g.,
> >    ip link set dev eth1
> > 
> > 
> > Looking at the code it appears to be this code path in addrconf.c:
> > 
> >          case NETDEV_DOWN:
> >          case NETDEV_UNREGISTER:
> >                  /*
> >                   *      Remove all addresses from this interface.
> >                   */
> >                  addrconf_ifdown(dev, event != NETDEV_DOWN);
> >                  break;
> > 
> > IPv4 addresses are NOT removed on a link down. Is there a particular 
> > reason IPv6 addresses are?
> > 
> > Thanks,
> > David
> 
> See RFC's which describes how IPv6 does Duplicate Address Detection.
> Address is not valid when link is down, since DAD is not possible.

It should be no problem if the kernel would reacquire them on ifup and
do proper DAD. We simply must not use them while the interface is dead
(also making sure they don't get used for loopback routing).

The problem the IPv6 addresses get removed is much more a historical
artifact nowadays, I think. It is part of user space API and scripts
deal with that already.

Bye,
Hannes
