From: Bill Fink <billfink@mindspring.com>
Subject: Re: ppp and routing table rules.
Date: Sat, 3 Mar 2007 00:54:55 -0500
Message-ID: <20070303005455.86dd8059.billfink@mindspring.com>
References: <45E7AC31.9030309@candelatech.com>
	<45E7C45F.9080805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:47323 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965085AbXCCGDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 01:03:50 -0500
In-Reply-To: <45E7C45F.9080805@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 01 Mar 2007, Ben Greear wrote:

> Ben Greear wrote:
> 
> I am sending udp packets through ppp400, and I see them appear on ppp401 
> as expected.
> 
> The thing that is bothering me is that all I see on rddVR4 (172.1.2.1) 
> is arps for 172.1.2.2, but the 'tell' IP is that of the
> originating ppp400 link, not the IP of rddVR4, as I expected:
> 
> 21:47:16.119640 arp who-has 172.1.2.2 tell 11.1.1.3
> 21:47:17.119371 arp who-has 172.1.2.2 tell 11.1.1.3
> 21:47:18.119254 arp who-has 172.1.2.2 tell 11.1.1.3
> 21:47:19.273118 arp who-has 172.1.2.2 tell 11.1.1.3
> 
> Unless I'm missing something dumb, a similar setup with all ethernet-ish 
> network devices
> works fine.
> 
> I have also enabled arp filtering:
> # Only answer ARPs if it is for the IP on our own interface.
> echo 2 > /proc/sys/net/ipv4/conf/all/arp_ignore
> and for every device used in these routing tables:
> echo 1 > /proc/sys/net/ipv4/conf/[dev]/arp_filter
> 
> Any idea what I need to do in order to make  the source IP for the ARP 
> packet correct?

Wouldn't that be controlled by arp_announce?

arp_announce - INTEGER
        Define different restriction levels for announcing the local
        source IP address from IP packets in ARP requests sent on
        interface:
        0 - (default) Use any local address, configured on any interface
        1 - Try to avoid local addresses that are not in the target's
        subnet for this interface. This mode is useful when target
        hosts reachable via this interface require the source IP
        address in ARP requests to be part of their logical network
        configured on the receiving interface. When we generate the
        request we will check all our subnets that include the
        target IP and will preserve the source address if it is from
        such subnet. If there is no such subnet we select source
        address according to the rules for level 2.
        2 - Always use the best local address for this target.
        In this mode we ignore the source address in the IP packet
        and try to select local address that we prefer for talks with
        the target host. Such local address is selected by looking
        for primary IP addresses on all our subnets on the outgoing
        interface that include the target IP address. If no suitable
        local address is found we select the first local address
        we have on the outgoing interface or on all other interfaces,
        with the hope we will receive reply for our request and
        even sometimes no matter the source IP address we announce.

        The max value from conf/{all,interface}/arp_announce is used.

        Increasing the restriction level gives more chance for
        receiving answer from the resolved target while decreasing
        the level announces more valid sender's information.

						-Bill
