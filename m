From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 4/9] netconsole: Introduce netconsole_netdev_notifier
Date: Wed, 4 Jul 2007 23:32:02 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707042314510.757@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110759.28520.37301.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704135925.GC11115@waste.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:40575 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbXGDRkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 13:40:39 -0400
In-Reply-To: <20070704135925.GC11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jul 2007, Matt Mackall wrote:
> On Wed, Jul 04, 2007 at 04:37:59PM +0530, Satyam Sharma wrote:
> > From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> > 
> > [4/9] netconsole: Introduce netconsole_netdev_notifier
> > 
> > To update fields of underlying netpoll structure at runtime on
> > corresponding NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.
> [...]
> I can have a host with DHCP that uses netconsole to log to a private
> network address. This breaks that.

Hmm, could you explain that a bit more?

(and the breakage that could happen?)

(1) Please note that NETDEV_CHANGEADDR is a response to SIOCSIFHWADDR,
i.e. when the _hardware_ or MAC address of the particular _local_
(ethernet) network interface device that the netpoll is attached to
(i.e. np->dev) is changed -- say using:

# ip link set eth0 set address 01:23:45:67:89:ab

This has nothing to do with DHCP / IP addresses, AFAICT.

(2) NETDEV_CHANGENAME is a response to SIOCSIFNAME, i.e. when the name
of the particular (ethernet) network interface device is changed,
say something like:

# ip link set eth0 name ieee80230

(which would rename "eth0" to "ieee80230")

So I'm not following how DHCP could pose problems for us (or private
network addresses of remote logging agent), sorry ...


On Wed, 4 Jul 2007, Matt Mackall wrote:
> On Wed, Jul 04, 2007 at 04:37:59PM +0530, Satyam Sharma wrote:
> > [...]
> > To update fields of underlying netpoll structure at runtime on
> > corresponding NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.
> 
> It's not obvious that we want to do that.

I'd want to retain this, if possible, please. Kindly note that configfs
makes all these attributes (that are members of struct netpoll) visible
from userspace -- so that user can both read and write to them. We
wouldn't want to display obsolete values for any of these parameters.
Say the interface was called "eth0" when the user / admin created the
target and "enabled" it. And say somewhere in between the interface
name got changed to "eth2". We wouldn't want the user to get obsolete/
incorrect information if / when he does a "cat dev_name" from
/config/netconsole/mytarget123/, for example.

Satyam
