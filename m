From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 23:43:05 +0400
Message-ID: <20060728194304.GC13690@2ka.mipt.ru>
References: <20060717155224.060020000@hp.com> <20060717155822.315389000@hp.com> <20060728112426.GE14627@postel.suug.ch> <44CA504C.6030207@hp.com> <20060728181225.GF14627@postel.suug.ch> <44CA59D8.4090702@hp.com> <20060728185825.GG14627@postel.suug.ch> <44CA60BC.1030503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, davem@davemloft.net, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30852 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161250AbWG1Tn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 15:43:59 -0400
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <44CA60BC.1030503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 03:08:44PM -0400, Paul Moore (paul.moore@hp.com) wrote:
> > Not a requirement but I would encourage it. Almost all netlink
> > families are using attributes with a few exceptions. We just
> > used to call them rtattr defined in rtnetlink.h before the new
> > api was added. There is one huge advantage in using attributes
> > which is that your protocol is extendable without breaking binary
> > interfaces.
> > 
> > What I'm refering to primarly are the existing functions to write
> > netlink and genetlink headers etc.
> 
> Okay.  Thanks for your feedback but unless I hear from others that this
> is a requirement I think I'm going to leave the code as written for the
> reasons I listed above.  I won't argue the fact that attributes may make
> life easier when extending existing messages/interfaces but I think the
> existing NetLabel message format as well as the generic netlinks
> versioning of each message should allow plenty of room for growth in the
> future (if needed).

Attributes are usual for rtnetlink users way.
It complicates code and reading, but allows to have a lot of commands
inside your message (if one has not created special field himself), 
thus do not breaking existing interfaces. IT can be easily avoided by
introducing new commands in your protocol, which is essentially the same
as new attributes. It is just another way of representing the data.
For example connector (idealogical parent of gennetlink) does not have
such attributes, but has similar to your structures approach, so it is
only the way you like to represent your data.

> -- 
> paul moore
> linux security @ hp

-- 
	Evgeniy Polyakov
