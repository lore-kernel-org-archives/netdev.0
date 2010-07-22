From: jamal <hadi@cyberus.ca>
Subject: Re: mirred, redirect action vs. dev refcount issue
Date: Thu, 22 Jul 2010 06:11:21 -0400
Message-ID: <1279793481.2747.39.camel@bigi>
References: <20100721162426.5aa4b646@nehalam>
	 <20100721.163955.12041610.davem@davemloft.net>
	 <20100721165247.6d1dd879@nehalam>
	 <20100721.165802.111593910.davem@davemloft.net>
	 <20100721170024.60cd9ef4@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57086 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab0GVKLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 06:11:25 -0400
Received: by iwn7 with SMTP id 7so7769426iwn.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 03:11:25 -0700 (PDT)
In-Reply-To: <20100721170024.60cd9ef4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-07-21 at 17:00 -0700, Stephen Hemminger wrote:
> On Wed, 21 Jul 2010 16:58:02 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 

> > Whether the ifindex or the global list + delete scheme is better is a
> > topic for discussion.  Since from the user's perspective it is unclear
> > which semantic is less surprising, entries disappearing or suddenly
> > stop working (or start applying to a different device which has taken
> > a previous one's ifindex!).
> 
> ifindex is unique (until integer wraps) so that soft reference
> works.

The proper way to do it is via a notifier since we point to the
netdev - and yes it is a little more complex thats why i just
let the admin suffer (IMO) the well deserved consequences[1].

I am in travel mode - but i will do some background thinking and
come up with a good way to resolve it when i get back. Unless you
have a patch you want me to look at.

cheers,
jamal

[1] least element of suprise principle:
Admin adds a rule which says
"you see a packet matching blah incoming on eth0,
do action1 then action2 ... then actionN"
Say action2 is "mirror to ifb0".
And then this same admin goes and rmmods ifb0 - it is easier to
just reject this rmmod operation as we do todau. Maybe we could be 
kinder and be more informative and syslog something along the lines of
"rejected to unregister device you rat-bastard because you have a rule
which says we should mirror to ifb0". 
Thoughts?


