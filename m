From: "Gerd v. Egidy" <lists@egidy.de>
Subject: -j MARK in raw vs. mangle (was Re: xfrm by MARK: tcp problems when mark for in and out differ)
Date: Thu, 14 Oct 2010 16:14:12 +0200
Message-ID: <201010141614.12940.lists@egidy.de>
References: <201010131557.06588.lists@egidy.de> <201010141501.59145.lists@egidy.de> <1287062098.3756.9.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:43147 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790Ab0JNOOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 10:14:22 -0400
In-Reply-To: <1287062098.3756.9.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

thanks for your help.

> > So it seems like the fl->mark is never initialized with the packet mark
> > in the first place. What would be the correct stage in the kernel
> > network stack to do that?
> 
> Can you try a simple setup without xfrm/ipsec and see if this reverse
> path works? Was there a kernel where it worked?

I just tried opening a simple tcp connection without any xfrm or other weird 
stuff. I just had one iptables rule in place:

-t raw -A OUTPUT -d 192.168.5.200 -j MARK --set-mark 99

192.168.5.200 is the other system I open the tcp connection from. So this 
should mark all response packets to the client.

But the moment __xfrm_lookup is called (this is where my debug printk sits), 
fl->mark is always 0.

By chance I changed the rule over to the mangle table:

-t mangle -A OUTPUT -d 192.168.5.200 -j MARK --set-mark 99

Now it works, the mark in the flow is 99!

So it seems this has nothing to do with xfrm, but that the MARK target has 
different effects when used in raw than in mangle. I was using raw because I 
had to set conntrack zones too and it was more conveniant to do both in one 
place.

Can one of the netfilter guys comment on this? Is using MARK in raw not fully 
supported or has known deficiencies?

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
