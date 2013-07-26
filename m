From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: igmp: Reduce Unsolicited report interval to 1s when using IGMPv3
Date: Fri, 26 Jul 2013 18:39:13 +0200
Message-ID: <20130726163913.GG3890@order.stressinduktion.org>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374754445-5608-1-git-send-email-william.manley@youview.com> <20130726163239.GE3890@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: William Manley <william.manley@youview.com>,
	netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41543 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756941Ab3GZQjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 12:39:14 -0400
Content-Disposition: inline
In-Reply-To: <20130726163239.GE3890@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 06:32:39PM +0200, Hannes Frederic Sowa wrote:
> On Thu, Jul 25, 2013 at 01:14:04PM +0100, William Manley wrote:
> > If an IGMP join packet is lost you will not receive data sent to the
> > multicast group so if no data arrives from that multicast group in a
> > period of time after the IGMP join a second IGMP join will be sent.  The
> > delay between joins is the "IGMP Unsolicited Report Interval".
> > 
> > Previously this value was hard coded to be chosen randomly between 0-10s.
> > This can be too long for some use-cases, such as IPTV as it can cause
> > channel change to be slow in the presence of packet loss.
> > 
> > The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
> > IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
> > later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
> > unaffected.
> > 
> > Tested with Wireshark and a simple program to join a (non-existent)
> > multicast group.  The distribution of timings for the second join differ
> > based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.
> >
> > [...]
> >
>
> [...]
> 
> Otherwise I am fine with it.

Also, could you have a look at IPv6, too? We currently use a hardcoded
IGMP6_UNSOLICITED_IVAL = 10*HZ there.

Thanks,

  Hannes
