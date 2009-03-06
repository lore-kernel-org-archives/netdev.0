From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 15:25:29 +0100
Message-ID: <49B13259.9040701@trash.net>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net> <m1sklqohw2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64049 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbZCFOZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 09:25:33 -0500
In-Reply-To: <m1sklqohw2.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>> So modify macvlan creation to allow automatically forward
>>> a creation of a macvlan on a macvlan to become a creation
>>> of a macvlan on the underlying network device.
>> I'm not sure I understand the constallation, what is the underlying
>> device in this case? A device outside the namespace?
> 
> Yes.
> 
> Typical usage would be:
> 
> eth0 in the initial namespace.
> A macvlan off of eth0 in each child namespace.
> 
> Which works fine until I do things like create a network namespace
> when I am already inside of a network namespace.  A child of a child.
> In which case I have to start rigging up something like a pair of
> veths an bridging or routing to get outside connectivity.
> 
> Or roughly:
> ip link add mv0 link eth0 type macvlan.
> ip link add mv1 link eth0 type macvlan.
> ip link set mv0 netns 1234
> ip link set mv1 netns 6789
> 
> Then later I would find it very handy to do:
> echo $$ -> 1234
> ip link add mv3 link mv0 type macvlan
> ip link set mv3 netns 101112

That makes sense of course. I'm mainly wondering whether a namespace
should be able to directly affect the real device like this. This
might move it to promiscous mode, or affect other performce-relevant
settings. Its also looks like you can steal the MAC address of a
different macvlan device this way and have the packets directed to you
(new devices are added to the beginning of the hash chains, so they
are found first on lookups).
