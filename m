From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 13:19:37 -0400
Message-ID: <1151687977.5270.91.camel@jzny2>
References: <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>
	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>
	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>
	 <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch>
	 <1151678118.5270.45.camel@jzny2>  <20060630163229.GH14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:46741 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932639AbWF3RTj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:19:39 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwMed-0001iy-0P
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 13:19:43 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630163229.GH14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 18:32 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 10:35
 
> > Did you actually try to run this before you reached this conclusion?
> 
> I did, fortunately some other bug prevents this from happening,
> packets are simply dropped somewhere.
> 

It is not a bug, Thomas! I am getting a little frustrated now.
The packets will be dropped because we set the at field to zero which is
invalid. That is done on purpose. It is only meaningful for ifb. The
challenge is much bigger than it appears. You could end up deadlocking
on the tx lock. So this was the choice i had to make.

> > With all due respect, the architecture works. I have invested many many
> > hours testing and verifying. There may be coding bugs - and those need
> > fixing. Kill the bugs.
> 
> Right, just run this
> 
> tc filter add dev eth0 parent 1: protocol ip prio 10
>               u32 match ip tos 0 0 flowid 1:1
> 	      action mirred egress redirect dev ifb1
> tc filter add dev ifb1 parent 1: protocol ip prio 10
>               u32 match ip tos 0 0 flowid 1:1
> 	      action mirred egress redirect dev ifb0
> 
> 
> Anyways, I give up. 

I understood you when you first posted. This is part of my testing. 
Try also to redirect from the same device eth0 to eth0 etc and see some
more interesting things.

> Last time I've been running after you trying
> to fix the many bugs you leave behind. Ever noticed that whenever
> you add some new code it's someone else following up with tons of
> small bugfix patches having a hard time trying to figure out the
> actual intent. 

You could always ask instead of making assumptions. And dont get me wrong, I 
honestly do appreciate you fixing bugs. You have been great and i have
always thanked you - except in situations like this where you just
stress the hell out of me. Bugs will always be there. 
Even God has bugs - but you are not fixing bugs in this case. 

You are attempting to change architecture (which works just fine) in the way you 
think it should work - and then point to something as a bug because it 
doesnt work the way you think it should work. 
This is a problem not just with you BTW, but with Patrick as well (although he has 
gotten better lately). There is a huge difference for example when dealing with 
Herbert. My approach in situations like this, which you dont have to follow, is 
to ask first what the intent was then if i dont like the intent try to convince the
owner that there maybe better ways. Or why they are wrong. 

To make my case, look at what you just did above in just the last 2 emails: 
You made a claim there is a bug. 
I asked you if you had really tested what you are pointing to (because i
know i test for that). You come back and make claims the bug is
elsewhere. This could go on forever typically - and infact it is throughout this
thread. 
Didnt ask if this is perhaps the way it is supposed to work or what the
intent was. It has to be a bug and by golly you are fixing it. Put yourself in 
my shoes.

> I'll just duplicate the code for my purpose, so
> much easier.
> 

Well, I am sorry you feel that way. I dont even remember where it is that 
we started.

cheers,
jamal

