From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v2 3/3] net: sched: fall back to noqueue when
 removing root qdisc
Date: Sun, 23 Aug 2015 20:53:57 +0200
Message-ID: <20150823205357.5df72804@redhat.com>
References: <1440202856-1645-1-git-send-email-phil@nwl.cc>
	<1440202856-1645-4-git-send-email-phil@nwl.cc>
	<20150823204442.2e032436@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, brouer@redhat.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbbHWSyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 14:54:00 -0400
In-Reply-To: <20150823204442.2e032436@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Aug 2015 20:44:42 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Sat, 22 Aug 2015 02:20:56 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > When removing the root qdisc, the interface should fall back to noqueue
> > as the 'real' minimal qdisc instead of the default one. 
> 
> I worry this behavior could break existing scripts.

You would break OpenWRT package "qos-scripts", specifically:
 https://github.com/openwrt-mirror/openwrt/blob/master/package/network/config/qos-scripts/files/usr/bin/qos-stop

Which cleans-up/clear the qdisc setup by removing the root qdisc,
assuming and depending on the default qdisc is re-assigned.


> I prefer the idea of allowing tc command to assign noqueue (to any
> device).  This makes the action explicit for the user, instead of being
> a side-effect of removing a qdisc. (and does not break backward compat)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
