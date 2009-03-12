From: feldmaus <feldmann_markus@gmx.de>
Subject: Re: no IPv6 Routers present
Date: Thu, 12 Mar 2009 23:32:27 +0000 (UTC)
Message-ID: <loom.20090312T232059-421@post.gmane.org>
References: <gpbtfk$s5h$1@ger.gmane.org> <49B99811.6050304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:38204 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbZCLXcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 19:32:46 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LhuOI-00005h-58
	for netdev@vger.kernel.org; Thu, 12 Mar 2009 23:32:42 +0000
Received: from dslb-092-076-238-059.pools.arcor-ip.net ([92.76.238.59])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 23:32:42 +0000
Received: from feldmann_markus by dslb-092-076-238-059.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 23:32:42 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich <at> hp.com> writes:

> You need to give more information about your interface configurations,
> routes, and any firewall rules.
First of all thank you for your answer,

first i post my specifications if my system works well:
/etc/network/interfaces:
########################################################################
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

iface dsl-provider inet ppp
    pre-up /sbin/ifconfig eth0 up -arp 0 # line maintained by pppoeconf
    provider dsl-provider
########################################################################

$route -n
########################################################################
Ziel            Router          Genmask         Flags Metric Ref    Use Iface
92.76.224.1     0.0.0.0         255.255.255.255 UH    0      0        0 ppp0
0.0.0.0         0.0.0.0         0.0.0.0         U     0      0        0 ppp0
########################################################################

iptables -L -n -v -->  <http://nopaste.debianforum.de/19638>
firewall for <ppp0> --> <http://nopaste.debianforum.de/19647>
firewall for <eth0> --> <http://nopaste.debianforum.de/19648>

Both firewall script will be started about:
</etc/network/if-up.d/startfirewall> --> <http://nopaste.debianforum.de/19636>
and stoped:
</etc/network/if-post-down.d/stopfirewall> --> <http://nopaste.debianforum.de/19637>

I hope that is not to much. :-)

I post next time a specification which failed !

In both firewall scripts i use:
echo 1 >/proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o "$DSLIF" -j MASQUERADE

I am not sure whether this could let it fail,
when both script will be executed ?

Regards Markus

