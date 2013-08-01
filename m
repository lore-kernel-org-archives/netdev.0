From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Thu, 1 Aug 2013 15:00:58 +0200
Message-ID: <20130801130058.GA13602@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <20130801121142.GA444@www.manty.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Santiago Garcia Mantinan <manty@manty.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:51999 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab3HANQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 09:16:03 -0400
Content-Disposition: inline
In-Reply-To: <20130801121142.GA444@www.manty.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 02:11:42PM +0200, Santiago Garcia Mantinan wrote:
> Hi!
> 
> I'm trying to setup a bond of a couple of vlans, these vlans are different
> paths to an upstream switch from a local switch.  I want to do arp
> monitoring of the link in order for the bonding interface to know which path
> is ok and wich one is broken.  If I set it up using arp monitoring and
> without using vlans it works ok, it also works if I set it up using vlans
> but without arp monitoring, so the broken setup seems to be with bonding +
> arp monitoring + vlans. 

This have helped me troubleshoot various bonding problems in the past:
mount -t debugfs none /sys/kernel/debug/
ln -s /sys/kernel/debug /debug
echo -n 'module bonding +p' > /debug/dynamic_debug/control

> The broken setup seems to work but arp monitoring makes it loose the logical
> link from time to time, thus changing to other slave if available.  What I
> saw when monitoring this with tcpdump is that all the arp requests were
> going out and that all the replies where coming in, so acording to the
> traffic seen on tcpdump the link should have been stable, but
> /proc/net/bonding/bond0 showed the link failures increasing and when testing
> with just a vlan interface I was loosing ping when the link was going down.

Did you sniff externally, on the native device, bond slaves or on bond0?

//E
