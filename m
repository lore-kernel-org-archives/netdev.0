From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next 0/6] Allow bridge to function in non-promisc
 mode
Date: Thu, 25 Apr 2013 19:45:27 +0300
Message-ID: <20130425164527.GA2908@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
 <20130425085656.4500d5c4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758855Ab3DYQph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 12:45:37 -0400
Content-Disposition: inline
In-Reply-To: <20130425085656.4500d5c4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 08:56:56AM -0700, Stephen Hemminger wrote:
> On Fri, 19 Apr 2013 16:52:44 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
> > This series is an almost complete rework of the prior attempt
> > to make the bridge function in non-promisc mode.  In this series
> > the "promiscuity" of an interface is dynamically determined and
> > the interface may transition from/to promiscuous mode based on
> > bridge configuration.
> > 
> > The series keeps an idea of an "uplink" port.  That is still user
> > designated.
> > The series also adds a concept of "dynamic" bridge port.  This is
> > the default state of the port and means that the user has not
> > specified any static FDBs for that port.
> > Once a user has added a static FDB entry to port and also specified
> > an "uplink" flag for that FDB, the mac address from that FDB is
> > added to the bridge hw address list and synched down to uplinks.
> > "Uplinks" are always considered dynamic ports even if a static entry
> > has been added for them.
> > Promiscuity is determined by the number of dynamic ports.  If there
> > are no dynamic ports (i.e all ports have static FDBs set), then we
> > know all the neighbors and can switch promisc off on all of the ports.
> > If we have only 1 dynamic port and its an uplink, we can synch all
> > static hw addresses to this port and mark it non-promisc.
> > If we have more then 1 dynamic port, then all ports have to be
> > promiscuouse.
> > This is the algorith that Michael Tsirkin proposed earlier.
> 
> Instead of a uplink port, maybe this idea would work better in combination
> with another patch I have been working on.
> 
> In many bridged environments, ports have only one possible MAC address
> on the other side. My patch provides a flag to mark those ports as bound
> with only one peer MAC address.  This allows those ports to be skipped on
> flooding, and for security only packets with that source address would
> be allowed.
> 
> After that change, your promicious code could just use that flag:
> i.e: 
>    uplink ports = total ports - bound ports
>    if (uplink ports == 1)
>        enter non-promicious mode

Almost except sometimes (with some guests)
X mac addresses are needed, not just one.

How about a generalization:
	- a flag to disable learning per port (only use static entries)
	- a flag to disable flood per port
Both sees to exist on openbsd, they are useful by themselves.

Now Vlad's patch can work if both learning and flood are
disabled for all ports except maybe one.


-- 
MST
