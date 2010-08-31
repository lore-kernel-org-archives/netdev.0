From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 19:43:52 +0200
Message-ID: <201008311943.52955.arnd@arndb.de>
References: <20100830062755.GA22396@verge.net.au> <201008311348.55883.arnd@arndb.de> <43F901BD926A4E43B106BF17856F0755F6432E3E@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:64101 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250Ab0HaRoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 13:44:16 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F6432E3E@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 31 August 2010, Rose, Gregory V wrote:
> >
> >Exactly! The problem is that I don't think any edge virtual bridge
> >can ever implement the full set of features we have in software,
> >and for this reason I wouldn't spend too much time in adding a small
> >subset of the features.
> 
> Not sure I agree there.  I've gotten specific requests for a small
> number of features that would make an embedded NIC switch useful
> to some customers.

That should be fine. Adding a small number of features probably
works well enough using extensions to the existing VF_INFO netlink
attributes, like a way to configure ports into VEPA mode.

I'm totally fine with making small additions here, which is something
completely different from extending the interface to the point where
it mimics all the features we have in the linux bridge code.
  
> No need to implement all of them but there are a small subset of
> useful rules and associated actions that would be very useful on
> the embedded switch of an SR-IOV capable NIC.  And these rules 
> and actions would actually promote security from my point of view.
> I agree that the embedded NIC switch will never (and should never)
> attempt to implement all the features a full fledged external
> switch.  But as things stand now embedded NIC switches are so 
> dumb as to be almost useless for most security conscious
> virtualized applications.  With the implementation of a small 
> set of rules and associated actions we could make them more
> useful for a number of our customers.

Right. Can you share your specific requirements with the rest of us?
Maybe start a new email thread with the same people on it, since
this is now really an Open vSwitch topic.

> Alright, I'm sort of new to Linux.  Most of my past experience 
> is in the embedded space and is more device oriented so I
> definitely appreciate getting your perspective on this.
> Like many folks I just have product features that I need to make 
> available to customers.  Finding a way to do this that is 
> acceptable to the Linux community and promotes the common welfare
> (so to speak) is all I'm trying to do here.

Ok, cool. Now I think that getting an interface that fits the needs
of the NIC and Open vSwitch would be great for both Open vSwitch and
every NIC vendor implementing it, because it means that you can simply
add a smart NIC and Open vSwitch will run faster without any changes to
the software setup.
Even better for you if you are the first one on the market to implement
it in hardware ;-)

You should probably take a look at the current ioctl based implementation
in Open vSwitch and figure out if you could make that interface would work
on your NIC, and if not, tell us all what is missing to make that work
with the new interface.

	Arnd
