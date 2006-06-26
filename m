From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Mon, 26 Jun 2006 13:21:13 +0200
Message-ID: <449FC329.7080609@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net>	 <1151001712.5392.47.camel@jzny2>  <449BFB82.9000008@trash.net> <1151159997.6716.116.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58010 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965010AbWFZLWQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 07:22:16 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151159997.6716.116.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2006-23-06 at 16:32 +0200, Patrick McHardy wrote:
> 
>>I don't think it should carry both old and new speed. Netlink
>>notifications usually provide a snapshot of the new state, but
>>no indication what changed, with one notable exception, the
>>ifi_change field, which IMO is a hack for lazy userspace. 
> 
> 
> I am quiet fond of the ifi_change ;->
> 
>>Since
>>notifications can get lost, userspace needs to resync occasionally.
>>The naiive approach (works for every other object) to determine if
>>the object state changed from my last known state is to compare
>>all attributes ..
> 
> 
> scalability issues abound when you have a gazillion things to look at.
> There used or may still be a way to tell from looking at netlink socket
> that an error occurred since last time - such as "a message was lost".
> You could use that to tell a message was lost and do scanning only
> then.  

It returns -ENOBUFS on socket overrun. Without it netlink notifications
wouldn't be very useable as you couldn't figure out when you missed
some.

>> but the ifi_change field will be different
>>between notifications and dumps even if the object itself didn't
>>change. "Lazy userspace" because looking at ifi_change is obviously
>>only useful if it doesn't keep its last known state and tries to
>>derive the change from update notifications alone .. which means it
>>fails when notifications are lost.
>>
> 
> 
> But thats not the real intent for it. 

Then what is the intent, it doesn't carry any other information?
It includes information that are not available any other way from
the kernel, yet the information is not transmitted reliably. How
could a program that relies on this possibly work reliable?

