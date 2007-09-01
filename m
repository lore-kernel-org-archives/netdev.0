From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipv4_get_l4proto: Frag of proto 17
Date: Sat, 01 Sep 2007 07:28:26 +0200
Message-ID: <46D8F87A.1080604@trash.net>
References: <Pine.SOC.4.64.0708211355310.24028@math.ut.ee>	<46D66D00.7060801@trash.net> <Pine.SOC.4.64.0708301557400.9520@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46522 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbXIAF34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 01:29:56 -0400
In-Reply-To: <Pine.SOC.4.64.0708301557400.9520@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
>>> Yesterdays git snapsot on a normal home PC spams dmesg with the following
>>> line:
>>> ipv4_get_l4proto: Frag of proto 17
>> In what situation does this happen?
> 
> It happens some times every hour on the average. Seems to be some UDP 
> traffic. Firewall allows in any UDP that is ESTABLISHEFD,RELATED, DHCP 
> (some more UDP rules with counter 0 so not important). Additionally 
> there is internal netowkr that sometimes has a laptop but usually not 
> and the messages have appeared also when there is nothin in the internal 
> network.
> 
> Locally mldonkey is probably using UDP, and lsof -i | grep UDP tells 
> that named, avahi-daemon, dhcpd, chronyd, nmbd and cupsd are listening 
> on UDP sockets (most of them on internal network).
> 
> But I have no idea what application is causing the messages.


I'm guessing that its ICMP errors containing UDP fragments.

Could you add a WARN_ON(1) to ipv4_get_l4proto() in
net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c to verify
this?

