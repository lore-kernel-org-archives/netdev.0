From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Thu, 23 Sep 2010 16:58:56 +0200
Message-ID: <20100923145856.GB1160234@jupiter.n2.diac24.net>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
 <m1hbhgq1v1.fsf@fess.ebiederm.org>
 <1285240926.5036.7.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:45569 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015Ab0IWO7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 10:59:09 -0400
Content-Disposition: inline
In-Reply-To: <1285240926.5036.7.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 07:22:06AM -0400, jamal wrote:
> On Thu, 2010-09-23 at 01:51 -0700, Eric W. Biederman wrote:
> > Take advantage of the new abstraction and allow network devices
> > to be placed in any network namespace that we have a fd to talk
> > about.
> 
> So ... why just netdevice? could you allow migration of other
> net "items" eg a route table since they are all tagged by
> netns?

migrating route table entries makes no sense because
a) they refer to devices and configuration that does not exist in the
   target namespace; they only make sense within their netns context
b) they are purely virtual and you get the same result from deleting and
   recreating them.

Network devices are special because they may have something attached to
them, be it hardware or some daemon.


-David

