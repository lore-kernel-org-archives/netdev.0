From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.0-test4, 2.5.47, child qdiscs, parent not filled out?
Date: 05 Sep 2003 08:00:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062763235.1459.14.camel@jzny.localdomain>
References: <Pine.LNX.4.33.0309032258290.521-100000@devix>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: devik <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.33.0309032258290.521-100000@devix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

olla,

Actually HTB does seem to be missing something; havent looked at the
code - just looking at a black box perspective. Try a very simple test:

Add a root CBQ qdisc and watch the netlink messages produced.
Observe CBQ creating both a root qdisc and class where the children
will be attached.

Repeat same test for HTB - it doesnt create the top class.
I believe it is needed. Sorry too tied up elsewhere to help right now.

cheers,
jamal

On Wed, 2003-09-03 at 17:01, devik wrote:
> > Devik (I hope we can be friends again :-)), others,
> 
> yep I think so :-)
> 
> > If I create a cbq with several classes, and attach a qdisc to those classes,
> > a later netlink dump (RTM_GETQDISCS) returns parent as 0:0 for that qdisc,
> > is this right?
> 
> structure Qdisc has DEPRECATED field __parent pointing to parent
> qdisc (aparently CBQ needs it).
> There is no other "parent" info in the struct so it can't be returned
> IMHO.
> You will have to parse all clases from root to leaves.
> 
> Maybe we could add parent handle to qdisc but it is question to
> Alexey probably - I'm not sure how complex would it be to keep
> the field in sync ...
> 
> devik
> 
> 
> 
