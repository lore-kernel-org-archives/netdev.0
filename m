From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: no IPv6 Routers present
Date: Fri, 13 Mar 2009 07:55:50 -0400
Message-ID: <49BA49C6.2020007@hp.com>
References: <gpbtfk$s5h$1@ger.gmane.org> <49B99811.6050304@hp.com> <loom.20090313T082825-818@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: feldmaus <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:21428 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbZCMLzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 07:55:54 -0400
In-Reply-To: <loom.20090313T082825-818@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

feldmaus wrote:
> Vlad Yasevich <vladislav.yasevich <at> hp.com> writes:
> 
>> You need to give more information about your interface configurations,
>> routes, and any firewall rules.
> Next Bug, but this one should refer to the kernel i think:
> This one works not. --> <http://nopaste.debianforum.de/19665>
> 
> But this one works not --> <http://nopaste.debianforum.de/19664>
> 
> I worked out the syslog messages and the differences:
> In the not working configuration i used <NOARP> for eth0.
> I don't know why, but i think it come from ppp0 which
> uses it:
> ########################################################################
> iface dsl-provider inet ppp
>     pre-up /sbin/ifconfig eth0 up -arp 0 # line maintained by pppoeconf
>     provider dsl-provider
> ########################################################################
> 
> I also got some syslog Messages, this are for you:
> ########################################################################
> [  775.402699] host used greatest stack depth: 5672 bytes left
> ########################################################################
> 
> And i ran my <firewalllan> manually, so i got the following:
> ########################################################################
> iptables: Resource temporarily unavailable
> iptables: Resource temporarily unavailable
> iptables: Too many links
> iptables: Resource temporarily unavailable
> iptables: Too many links
> ########################################################################
> 
> I think this all comes from NOARP ?
> 
> Any Idea ?

You can't use NOARP on a normal network interface without some static neighbor
entries.  PPP interfaces do not require ARP since they are point-to-point
and you already know everything about the destination.  For ethernet interfaces,
you need arp to resolve the IP to MAC address mappings.

Get rid of NOARP in you eth0 case, and it should work.

-vlad

> 
> Regards Markus
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

