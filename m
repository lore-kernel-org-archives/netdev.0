From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 21:23:15 +0200
Message-ID: <200903022123.16032.denys@visp.net.lb>
References: <20090301204731.40ce346a@nehalam> <49AC2BD1.4070209@candelatech.com> <49AC2E32.2020403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:37472 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838AbZCBTXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 14:23:39 -0500
In-Reply-To: <49AC2E32.2020403@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 March 2009 21:06:26 Jarek Poplawski wrote:
> > Yes...the old way would tell you the vlan-id regardless of how
> > many NICs you have, which is useful information for anyone
> > actually trying to configure two boxes to talk to each other,
> > or (god forbid), debug someone else's config.
> >
> > It's true you can specify the vlan-name on creation using 'ip',
> > which is what I do, so I'm not going to argue Stephen's change
> > either way..but I do like device names that give more info...
>
> To make it clear: I don't say vlan0 is better; but IMHO it doesn't
> have to be silly or nothing useful either.
>
> Jarek P.
I guess for Linux it should be ethN.Y.

vlanN is Cisco and other switches behaviour, since they establish vlanN 
interfaces and bridge all vlan with numbers there. In best case they do 
remapping on receive.
So on linux similar alternative of cisco interface vlan100 will be:

ip link add link eth0 type vlan id 100
ip link add link eth1 type vlan id 100
brctl addbr vlan100
brctl addif vlan100 eth0.100
brctl addif vlan100 eth1.100

But on first two steps it creates for me vlan0 and vlan1, which is not very 
informative. I guess interface names should be intuitive, and should help to 
admin to find out for who vlan0 belongs without digging tons of files.

But another point... ip -d link   output is enough useful. I can find out 
easily who is who.
141063: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:0a:cd:16:82:74 brd ff:ff:ff:ff:ff:ff
    vlan id 100 <REORDER_HDR>
141070: vlan1@eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:0a:cd:16:82:69 brd ff:ff:ff:ff:ff:ff
    vlan id 100 <REORDER_HDR>

But IMHO ethN.Y more intuitive understandable.

