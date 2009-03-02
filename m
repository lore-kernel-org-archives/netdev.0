From: Patrick McHardy <kaber@trash.net>
Subject: Re: Vlan interface nuisance
Date: Tue, 03 Mar 2009 00:35:00 +0100
Message-ID: <49AC6D24.1030605@trash.net>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com> <49AC545E.3090708@trash.net> <20090302223011.GA3388@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57016 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbZCBXfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 18:35:06 -0500
In-Reply-To: <20090302223011.GA3388@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Mar 02, 2009 at 10:49:18PM +0100, Patrick McHardy wrote:
>> The binding is displayed when listing interfaces. This hole
>> argument is silly, if you want a particular name, just specify
>> it. The current naming schemes are entirely based on information
>> that you have to specify anyways.
> 
> Just for the record, I don't agree with calling "this" argument silly
> just like it was with "that" argument. Actually, I think they are
> both so "right" that I've changed my mind and think it's great each
> tool does it differently...

I'm not sure whether I'm supposed to understand this, so I'm going
to respond with something useful unrelated to naming user resources
that every virtual device author should know (and that seems to be
not well known):

Every virtual device bound to a different device should set the
dev->iflink field to the ifindex of the device bound to. This
makes every device related netlink message include this relation.
If the binding is already known at device-creation time and
relevant for the virtuals device's existance, this must be done
in the ->init callback to make sure its already included in the
first netlink creation message to avoid inconsistent information.

This is the also the prefered way device bindings should be
signaled to the kernel, and at least iproute and libnl are
aware of this in both directions. And to get back to the main
point of this discussion:

# ip l l
4: vlan0@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
     link/ether 92:2a:4f:ae:dc:29 brd ff:ff:ff:ff:ff:ff
