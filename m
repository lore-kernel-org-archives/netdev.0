From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Mon, 10 Jan 2005 22:17:47 +0100
Message-ID: <20050110211747.GA26856@postel.suug.ch>
References: <20050104223612.GN26856@postel.suug.ch> <1104894728.1117.56.camel@jzny.localdomain> <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain> <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain> <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105363582.1041.162.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105363582.1041.162.camel@jzny.localdomain> 2005-01-10 08:26
> I think its _a hack_ Thomas ;-> Mostly because it has dependency on u32.
> off2 doesnt exist on any other classifier and the basic ematch should be
> usable by any classifier.

It does not, u32 does have a dependency on em_u32 but not vice versa.
em_u32 is perfectly useful even without nexthdr functionality since
this is the way it is used today in 90% of the cases and it should be
a little bit faster than em_cmp but also a bit less powerful. On top
of that, rsvp could provide this information as well so one could
extend rsvp with em_u32 ematches. I think we should not think of it
as being dependant on off2 but rather as it is able to use information
from a underlying layer.

> Why not just have a check to see if it is native match then not to call
> up any ematch executing code. Have the native match maybe be of kind 0.
> Have the return code for ematch lookup return something that indicates
> that you need to match using local u32 instead of ematch.

This limits the number of native ematches to 1 or any other reserved
number and complicates userspace part for no reason. Is there any
advantage besides that it fits into layerrs more nicely? I can
tell you the disavantages and then we can compare ;->

 - additional code is required in the classifier which would not
   be required otherwise.
 - given we define 0 as native ematch, what happens if we need
   another native one? reserve a number in the namespace and
   make a comment, "please do not use" or will we just say,
   well, we can make it a regular ematch, it's not perfectly clean
   but it works perfectly fine?
 - making it a little bit generic such as em_u32 makes it useable
   by other classifiers. One example is the above mentioned
   rsvp which parses headers or there might be other specialized
   classifiers having use for it. we can't have this if its put
   into the classifier itself.
 - userspace needs additional special handling and this will
   get ugly once we need more than 1 native ematch, we'd need
   some register api so ematch modules could tell which numbers
   are native for them.
 - did i state it's more work already? ;->
