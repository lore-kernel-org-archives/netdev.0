From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Tue, 28 Dec 2004 15:50:33 +0100
Message-ID: <20041228145033.GB32419@postel.suug.ch>
References: <200412270715.iBR7Fffe026855@hera.kernel.org> <20041227121658.GI7884@postel.suug.ch> <1104240053.1100.53.camel@jzny.localdomain> <20041228134022.GA32419@postel.suug.ch> <1104242397.1090.94.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104242397.1090.94.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104242397.1090.94.camel@jzny.localdomain> 2004-12-28 08:59
> On Tue, 2004-12-28 at 08:40, Thomas Graf wrote:
> > * jamal <1104240053.1100.53.camel@jzny.localdomain> 2004-12-28 08:20
> 
> > > You mean meta match. 
> > 
> > Yes, I was thinking about implementing it as action, any objections?
> > 
> 
> 
> If you implement the mothership match changes we discussed then it
> should go as a match (as opposed to action). As an action its yet
> another deferal for later cleanup.

I'm getting more and more careful because we already suffer from
various limitations by design of underlying layers. I agree that the
best way would be to make it a generic match but we will end up
implementing logic expressions code for every layer over and over.
I have to think a little more about it, here's an up-to-date brain dump:

Classifier extensions should no longer be configured over classifier
specific TLV types but rather be part of a nested TLV. The extesions
should be changeable directly without going through the classifier
changing code, i.e. RTM_NEWFEXT/RTM_DELFEXT or something alike. It
should be possible to create logic relations between extensions like
match indev = "eth0" or (nfmark gt 10 or nfmark lt 4).

Doesn't sound too bad but we're actually just implementing things
on top of classifiers that should actually be on the same level.

> So my preference is to get the changes we discussed then this meta
> match.
> I could whip out meta action for setting values if you are gonna work
> on the match piece.

I was thinking of combining these by simply introducing an ASSIGN
operator so we don't have redundant code. We could make a generic
metadata api so netfilter could make use of it.

> Sounds reasonable at the high level. I am not sure i got the stats part.

Simple hit/success counters per match to be returned as separate TLV.

> Can you write out the BNF. Heres what i was thinking for meta action:

tc <OPERATION> meta [NOT] VALUE OPERATOR VALUE
VALUE ::= { METAVARS | number | pattern }
OPERATOR ::= { = | > | < | assign }

where: typeof(METAVAR) for every value pair must be equal
