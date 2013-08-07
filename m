From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 3/3] net: igmp: Allow user-space configuration of igmp unsolicited report interval
Date: Wed, 7 Aug 2013 03:00:41 +0200
Message-ID: <20130807010041.GG16410@order.stressinduktion.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com> <1375812195-6575-4-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35877 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab3HGBAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 21:00:42 -0400
Content-Disposition: inline
In-Reply-To: <1375812195-6575-4-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:03:15PM +0100, William Manley wrote:
> Adds the new procfs knobs:
> 
>     /proc/sys/net/ipv4/conf/*/igmpv2_unsolicited_report_interval
>     /proc/sys/net/ipv4/conf/*/igmpv3_unsolicited_report_interval
> 
> Which will allow userspace configuration of the IGMP unsolicited report
> interval (see below) in milliseconds.  The defaults are 10000ms for IGMPv2
> and 1000ms for IGMPv3 in accordance with RFC2236 and RFC3376.
> 
> Background:
> 
> If an IGMP join packet is lost you will not receive data sent to the
> multicast group so if no data arrives from that multicast group in a
> period of time after the IGMP join a second IGMP join will be sent.  The
> delay between joins is the "IGMP Unsolicited Report Interval".
> 
> Prior to this patch this value was hard coded in the kernel to 10s for
> IGMPv2 and 1s for IGMPv3.  10s is unsuitable for some use-cases, such as
> IPTV as it can cause channel change to be slow in the presence of packet
> loss.
> 
> This patch allows the value to be overridden from userspace for both
> IGMPv2 and IGMPv3 such that it can be tuned accoding to the network.
> 
> Tested with Wireshark and a simple program to join a (non-existent)
> multicast group.  The distribution of timings for the second join differ
> based upon setting the procfs knobs.
> 
> igmpvX_unsolicited_report_interval is intended to follow the pattern
> established by force_igmp_version, and while a procfs entry has been added
> a corresponding sysctl knob has not as it is my understanding that sysctl
> is deprecated[1].
> 
> [1]: http://lwn.net/Articles/247243/
> 
> Signed-off-by: William Manley <william.manley@youview.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
