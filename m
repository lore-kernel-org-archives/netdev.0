From: Richard Purdie <rpurdie@rpsys.net>
Subject: Re: Network activity LED trigger
Date: Fri, 02 Mar 2007 16:03:48 +0000
Message-ID: <1172851428.11149.140.camel@localhost.localdomain>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
	 <200703021358.52224.florian.fainelli@int-evry.fr>
	 <1172844668.4864.46.camel@localhost>
	 <200703021516.06638.florian.fainelli@int-evry.fr>
	 <1172848619.4845.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian.fainelli@int-evry.fr>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from tim.rpsys.net ([194.106.48.114]:60321 "EHLO tim.rpsys.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992555AbXCBQEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 11:04:13 -0500
In-Reply-To: <1172848619.4845.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-02 at 10:16 -0500, jamal wrote:
> Heres my view of what would be useful:
> Have them accessible via the kernel, but also have an API from user
> space. This way user space apps can control the LED, but if i wanted to
> do it from the kernel i could as well. In my case i was actually
> monitoring the health of a daemon; it would show off if the daemon was
> not running, green if it was happy, yellow if semi-healthy and Red if it
> was in trouble.

We already have this API, see drivers/leds ;-)

> here are some operations/messages i can see that are useful which you
> probably already have in your API:
> 
> turn on LED at #x color somecolor
> turn off LED at #y
> query LED info at #x
> dump all LEDs on board - think of this as a discovery
> flicker LED at #z at frequency y color green
> maybe even: "I am a wireless card with no LED, I claim LED #x"
> which is matched by "tell me if anyone owns LED code"
> 
> In other words, if you just provide mechanims let people write the
> policies.
> This way if i wanted to tie it to my eth0 i can. 

We have LEDs which show up in sysfs and can be controlled by userspace
from there. They can also choose to be controlled by kernel LED
'triggers', for example. we have an IDE disk trigger which shows up
activity on IDE disks. Florian would like to see a network trigger.

The LED trigger code is quite generic and designed to have little impact
on the subsystem its added to, at least in terms of code. As always,
there will be some runtime overhead though. Ultimately it depends how
complex you make the trigger (eg. how many options it has) and where and
how you hook it into the network subsystem. I know little about the
network subsystem so this is something others will have to advise on.

Cheers,

Richard 
(LED Maintainer)


