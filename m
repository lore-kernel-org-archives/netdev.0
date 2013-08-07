From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 1/3] net: igmp: Reduce Unsolicited report interval to 1s when using IGMPv3
Date: Wed, 7 Aug 2013 02:45:23 +0200
Message-ID: <20130807004523.GE16410@order.stressinduktion.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com> <1375812195-6575-2-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35841 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab3HGApZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 20:45:25 -0400
Content-Disposition: inline
In-Reply-To: <1375812195-6575-2-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:03:13PM +0100, William Manley wrote:
> If an IGMP join packet is lost you will not receive data sent to the
> multicast group so if no data arrives from that multicast group in a
> period of time after the IGMP join a second IGMP join will be sent.  The
> delay between joins is the "IGMP Unsolicited Report Interval".
> 
> Previously this value was hard coded to be chosen randomly between 0-10s.
> This can be too long for some use-cases, such as IPTV as it can cause
> channel change to be slow in the presence of packet loss.
> 
> The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
> IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
> later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
> unaffected.
> 
> Tested with Wireshark and a simple program to join a (non-existent)
> multicast group.  The distribution of timings for the second join differ
> based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.
> 
> Signed-off-by: William Manley <william.manley@youview.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
