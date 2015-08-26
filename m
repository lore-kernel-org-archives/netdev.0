From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH v2 3/3] net: sched: fall back to noqueue when
 removing root qdisc
Date: Wed, 26 Aug 2015 11:48:26 +0200
Message-ID: <20150826094825.GB20760@orbit.nwl.cc>
References: <1440202856-1645-1-git-send-email-phil@nwl.cc>
 <1440202856-1645-4-git-send-email-phil@nwl.cc>
 <20150823204442.2e032436@redhat.com>
 <20150823205357.5df72804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54791 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982AbbHZJs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 05:48:28 -0400
Content-Disposition: inline
In-Reply-To: <20150823205357.5df72804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

On Sun, Aug 23, 2015 at 08:53:57PM +0200, Jesper Dangaard Brouer wrote:
> On Sun, 23 Aug 2015 20:44:42 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > On Sat, 22 Aug 2015 02:20:56 +0200
> > Phil Sutter <phil@nwl.cc> wrote:
> > 
> > > When removing the root qdisc, the interface should fall back to noqueue
> > > as the 'real' minimal qdisc instead of the default one. 
> > 
> > I worry this behavior could break existing scripts.
> 
> You would break OpenWRT package "qos-scripts", specifically:
>  https://github.com/openwrt-mirror/openwrt/blob/master/package/network/config/qos-scripts/files/usr/bin/qos-stop

Thanks for pointing this out!

> Which cleans-up/clear the qdisc setup by removing the root qdisc,
> assuming and depending on the default qdisc is re-assigned.

OK. Since the premise of the whole thing is to not break existing
scripts, this sadly tears down my approach.

> > I prefer the idea of allowing tc command to assign noqueue (to any
> > device).  This makes the action explicit for the user, instead of being
> > a side-effect of removing a qdisc. (and does not break backward compat)

I will give this another go. What I didn't like was that after attaching
noqueue, tc would output nothing when asked to show the attached qdisc -
which is of debatable correctness at least. But maybe that's just a user
space problem I could address separately.

Cheers, Phil
