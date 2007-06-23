From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 10:26:40 -0700
Message-ID: <20070623102640.6f111d7e@oldman>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net>
	<467D3A48.20706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	jamal <hadi@cyberus.ca>, Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41708 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754389AbXFWRci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 13:32:38 -0400
In-Reply-To: <467D3A48.20706@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Jun 2007 08:20:40 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Patrick McHardy wrote:
> > Eric W. Biederman wrote:
> >   
> >> -- The basic design
> >>
> >> There will be a network namespace structure that holds the global
> >> variables for a network namespace, making those global variables
> >> per network namespace.
> >>
> >> One of those per network namespace global variables will be the
> >> loopback device.  Which means the network namespace a packet resides
> >> in can be found simply by examining the network device or the socket
> >> the packet is traversing.
> >>
> >> Either a pointer to this global structure will be passed into
> >> the functions that need to reference per network namespace variables
> >> or a structure that is already passed in (such as the network device)
> >> will be modified to contain a pointer to the network namespace
> >> structure.
> >>     
> >
> >
> > I believe OpenVZ stores the current namespace somewhere global,
> > which avoids passing the namespace around. Couldn't you do this
> > as well?

Maybe the current namespace should be attached to something else
like sysfs root? Having multiple namespace indirection possiblities
leads to interesting cases where current namespace is not correctly
associated with current sysfs tree or current proc tree, ...


> Will we be able to have a single application be in multiple name-spaces?

That would break the whole point of namespaces...

