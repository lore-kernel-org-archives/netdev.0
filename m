From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Trouble Shooting ipsec
Date: Tue, 8 Feb 2011 13:35:27 -0500
Message-ID: <20110208183527.GA7450@hmsreliant.think-freely.org>
References: <4D504563.5010802@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Clark <sclark46@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413Ab1BHSfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 13:35:36 -0500
Content-Disposition: inline
In-Reply-To: <4D504563.5010802@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 07, 2011 at 02:17:55PM -0500, Stephen Clark wrote:
> Hello,
> 
> How do I find out what is happening to my packets thru my ipsec tunnel.
> They just seem to disappear on the remote side.
> 
> I have successfully got the pings thru
> when everything has an ipv6 address, but am not successful when trying
> to connect two ipv4 lans across an ipv6 ipsec tunnel. All fw chains
> both 4 and 6
> are set to ACCEPT. NAT is turned off.
> 
>      eth0               eth1
> eth1                 eth0
> 10.1.254.254/17  2001:xxxx:1628::254 <----ipv6 internet ----->
> 2001:xxxx:e334::254  10.0.254.254/17
> 
> 12:00:02.296972 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254:
> ESP(spi=0x07454bc3,seq=0x28b), length 132
> 12:00:03.308751 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254:
> ESP(spi=0x07454bc3,seq=0x28c), length 132
> 12:00:04.296857 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254:
> ESP(spi=0x07454bc3,seq=0x28d), length 132
> 12:00:05.293748 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254:
> ESP(spi=0x07454bc3,seq=0x28e), length 132
> 12:00:06.296623 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254:
> ESP(spi=0x07454bc3,seq=0x28f), length 132
> 
> I have posted to the ipsec-devel list and haven't gotten any
> responses. Also I have spent 2 days googling with
> no results about the above setup. Is it even possible to tunnel ipv4
> packet thru an ipv6 ipsec tunnel?
> 
> Thanks,
> Steve
> 
I'd start by looking at your stats counters to see if you're dropping anything
significat.  It appears from what you have above that you're receiving end is
getting encapsulated packets, so at least your tunnel is functional.  Take a
look at proc/net/snmp and see if any counters get bumped as you send data.  I
expect you're loosing them somewhere during decode (which would show up in
/proc/net/xfrm_stat), or you're loosing them after you decode them and try to
receive/forward them (which would likely show up in /proc/net/snmp).  That
should give you a clue as to where to look next

Neil

> -- 
> 
> "They that give up essential liberty to obtain temporary safety,
> deserve neither liberty nor safety."  (Ben Franklin)
> 
> "The course of history shows that as a government grows, liberty
> decreases."  (Thomas Jefferson)
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
