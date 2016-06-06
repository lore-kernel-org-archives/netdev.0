From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/9] net: dsa: Add support for parsing the old
 binding
Date: Mon, 6 Jun 2016 05:19:36 +0200
Message-ID: <20160606031936.GK12165@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
 <20160604200016.GD2063@lunn.ch>
 <5754AAC6.3080701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60063 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763AbcFFDTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2016 23:19:39 -0400
Content-Disposition: inline
In-Reply-To: <5754AAC6.3080701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> How much support do we want to have for the old binding for in tree
> platforms? Is the plan to migrate them all to the new binding?

I think there are three cases to consider.

1) There are some old boards using setup.c files which have a platform
   device, platform data, etc. I've never used DSA in this way, and it
   could be all the recent additions have broken this. We might want
   to test this, and if it is in fact broken, and has been for a
   while, it indicates nobody uses those boards any more. We might
   suggest removing them. Even if they do work, i doubt anybody is
   interested in converting them to device tree. So we might have to
   keep the platform data support around.

2) In tree devices using the DT binding. We can update them all to the
   new binding. The kirkwood boards don't have a u-boot which is DT
   capable. Some of the armada boards do have a DT capable uboot, but
   all these boards have been added by the community, so i suspect
   they are not flashed never to be changed again.

3) Out of tree devices using the DT binding. As far as i can see,
   there is no in three board actually using the Broadcom SF2 driver
   and its odd binding. However from talking to you, i know there are
   devices out in the wild using this binding, and their DT blob is
   fixed, never to be changed again.

It actually seems odd to me that we have a nice new binding and an
implement which is reasonably clean, and we want to add code to
support a legacy binding for an out of tree board.

I need to think on this for a while. However, i don't see the old code
and binding going away anytime soon. It will take a few cycles to
determine if the old platform device/platform data still works, and to
remove the old boards if not. We can update the in tree devices to the
new binding, but we should keep the old binding a while to aid the
transition.

I'm tempted to say you should keep using the old code to support your
out of tree devices. You should define a new binding for SF2 which
conforms to the device tree binding document which just got accepted,
and add it to SF 2 alongside the legacy binding. And it would be great
if you could go the last step and actually add a boards device tree
file using it.

I'm hesitant to add legacy binding support for SF2 to the new DSA2
code. We should try to keep it free of cruft, and set a good example
for others to follow when they bring along there new drivers.

	Andrew
