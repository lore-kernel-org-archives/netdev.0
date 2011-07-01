From: David Lamparter <equinox@diac24.net>
Subject: Re: possible bridge regression in "bridge: implement [add/del]_slave
 ops"?
Date: Fri, 1 Jul 2011 12:08:33 +0200
Message-ID: <20110701100833.GA3988422@jupiter.n2.diac24.net>
References: <201106301033.23997.alexander.stein@systec-electronic.com>
 <20110630100819.0e4b536f@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Stein <alexander.stein@systec-electronic.com>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:47289 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755161Ab1GAKIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 06:08:45 -0400
Content-Disposition: inline
In-Reply-To: <20110630100819.0e4b536f@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2011 at 10:08:19AM -0700, Stephen Hemminger wrote:
> On Thu, 30 Jun 2011 10:33:23 +0200
> Alexander Stein <alexander.stein@systec-electronic.com> wrote:
> 
> > * echo $(pgrep rstpd) > /var/run/rstpd.pid
> > * brctl addbr br1
> > * echo 1 > /sys/class/net/br1/bridge/stp_state
> 
> This bogus. You are running both kernel and spanning
> tree daemon at the same time!
> 
> Doing the echo of 1 to stp_state forces kernel spanning
> tree. You want 2 which is what is supposed to be use for user
> mode spanning tree.

I just tested this on my box, you can't echo 2 into that sysfs file (it
reads back as 1).

That you can change this variable at all when an userspace stp
implementation is running is a bug anyway, IMHO. rstpd should do all the
required settings and the kernel should prevent them from being changed
while rstpd has the bridge under its control.


-David

