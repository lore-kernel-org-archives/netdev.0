From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 08:59:57 -0500
Message-ID: <1104242397.1090.94.camel@jzny.localdomain>
References: <200412270715.iBR7Fffe026855@hera.kernel.org>
	 <20041227121658.GI7884@postel.suug.ch>
	 <1104240053.1100.53.camel@jzny.localdomain>
	 <20041228134022.GA32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041228134022.GA32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 08:40, Thomas Graf wrote:
> * jamal <1104240053.1100.53.camel@jzny.localdomain> 2004-12-28 08:20

> > You mean meta match. 
> 
> Yes, I was thinking about implementing it as action, any objections?
> 


If you implement the mothership match changes we discussed then it
should go as a match (as opposed to action). As an action its yet
another deferal for later cleanup.
So my preference is to get the changes we discussed then this meta
match.
I could whip out meta action for setting values if you are gonna work
on the match piece.

> > >  We
> > > should really stop to add more stuff to specific classifiers which have
> > > to be removed once we have metamatch. I've made a proposal on paper
> > > just need some more time to cook up a patch.
> > 
> > I have cycles now. Are you working on this or should i invest some of my
> > cycles in it? Lets fix this once and for all.
> 
> I don't care, I'm still testing the patchset to make classifer changes
> consistent again. A few big changes to tcindex/route classifier need
> extensive testing.
> 

If you have started working on it i would prefer you make the changes.
BTW, I am talking about the top level match changes we discussed.

> My thoughts on meta match:
>   
>   A match consists of a header, lvalue, rvalue and stats. The header
>   contains the handle, the requested operand (eq,lt,gt) and a flag to
>   invert the meaning of the match. A value consists of a type and data
>   where type specifies the actual metadata to be used. A few upper bits
>   of the type specify the kind, i.e. wether it's numeric or a
>   bytestring. Only values with matching upper bits can be compared.
>   Additionally a mask and shift operator can be configured. Why so
>   complicated? Comparing two kernel meta values can useful, realdev
>   == indev when classyfing on tunnels, comparing backlogs, etc. Device
>   matches should be made available as both numeric and bytestring match
>   to have a fastpath when ifindex is stable and a slower path which is
>   more flexible to changes.

Sounds reasonable at the high level. I am not sure i got the stats part.

Can you write out the BNF. Heres what i was thinking for meta action:

tc <OPERATION> action metaset [index ID] METAVARS
OPERATION:= ADD|DEL|GET|DUMP
METAVARS:= <[INDEV] [FWMARK] [TCINDEX] [PRIO] [CLASSID]>
INDEV = indev <devname>
FWMARK:= fwmark <value>
TCINDEX := tcindex <value>
PRIO := prio <value>
CLASSID := classid <class>

I notice you throw in some  mask and shift operator - not sure if i
could make use of it here.

cheers,
jamal
