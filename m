From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Wed, 22 Dec 2004 15:26:37 +0100
Message-ID: <20041222142637.GE7884@postel.suug.ch>
References: <20041219203050.GK17998@postel.suug.ch> <41C68CEF.3030803@trash.net> <1103552215.1048.333.camel@jzny.localdomain> <20041220200739.GX17998@postel.suug.ch> <41C7F833.4000909@trash.net> <20041222003142.GB7884@postel.suug.ch> <1103722366.1089.75.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103722366.1089.75.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103722366.1089.75.camel@jzny.localdomain> 2004-12-22 08:32
> On Tue, 2004-12-21 at 19:31, Thomas Graf wrote:
> > * Patrick McHardy <41C7F833.4000909@trash.net> 2004-12-21 11:17
> > > Could you make your patchset available somehow ?
> > 
> > http://people.suug.ch/~tgr/patches/queue/
> > 
> > Unfinished and untested.
> 
> I just took a quick glimpse. 
> 
> 1)Recall: Policer will have to die at some point - only reason for its
> existence is for backward compat.
> New iproute2 code sooner than later stop using that inteface so we can
> kill it. I suspect we can kill it in a year or two and definetely the
> day 2.7 comes out.

I fully agree. The patchset looks like a beautification but it isn't.
Its main purpose is to make changing consistent again. I tried
achieving this with the existing API and the ifdef hell got horrible
and ended up having over 60 lines of redundant code per classifier.
I would rather be implementing new fancy stuff but fixing the existing
issues comes first.

> 2) The name tcf_attrs doesnt sound right - attributes are normally
> data pieces not methods. Cant think of a good name.

I feel the same, I was thinking of extensions but wasn't pleased either.
Suggestions appreciated.

> 3) What can i say? dang - this indev thing is getting out of control ;->

Too late, it's there, we must maintain it ;->

> If you are going to go this far for beautification sake then
> kill the .indev thing please before it becomes a beast.

Again, it's not for beautification, validating the indev tlv must be
done before changing native classifier attributes which lead to
more ifdefs. Putting it into tcf_attrs saves code and makes it
available to the other classifiers at the same time. It's a dodgy
situation, the current status is unsatisfying and all changes
made now will be removed again.

> Do what we discussed a while back:
> - have a generic very basic extended generic match API which indev uses
> that gets invoked from  the classifier. It should take no more than one
> page to write the indev extension - if it exceeds that you are doing
> something wrong. There should be capability to mix and match these
> extenders so i can say in u32 something like:
>  match ip src X
>  match extend indev src eth0
>  match protocol tcp
>  match extended metadata fwmark 0x10

My actual plan was to introduce a nested TCA_TYPE_ATTRS TLV
containing all the generic matches and attributes so a classifier
no longer has to be changed but the backward compatibility will
be a PITA.

> I think its time we did this right than defering.

Indeed, what about this: I'll try and do a proposal on a new
generic matching layer holding the action bits and providing
backward compatibility to police/indev. We can then build the
metadata match on top of it. I'm going to post the classifier
I'm working on for a long time even if it's still buggy and
unfinished so we can at least take over some ideas and concepts
and then come up with something final that doesn't need to be
changed again in 2 months.
