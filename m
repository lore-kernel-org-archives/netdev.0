From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Fri, 24 Sep 2010 07:51:24 -0400
Message-ID: <1285329084.13976.661.camel@bigi>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	 <m1hbhgq1v1.fsf@fess.ebiederm.org> <1285240926.5036.7.camel@bigi>
	 <20100923145856.GB1160234@jupiter.n2.diac24.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
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
To: David Lamparter <equinox@diac24.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100923145856.GB1160234@jupiter.n2.diac24.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 16:58 +0200, David Lamparter wrote:

> migrating route table entries makes no sense because
> a) they refer to devices and configuration that does not exist in the
>    target namespace; they only make sense within their netns context
> b) they are purely virtual and you get the same result from deleting and
>    recreating them.
> 
> Network devices are special because they may have something attached to
> them, be it hardware or some daemon.

Routes functionally reside on top of netdevices, point to nexthop
neighbors across these netdevices etc. Underlying assumption is you take
care of that dependency when migrating.
We are talking about FIB entries here not the route cache; moving a few
pointers within the kernel is a hell lot faster than recreating a subset
of BGP entries from user space. 

Eric, I didnt follow the exposed-races arguement: Why would it involve
more than just some basic locking only while you change the struct net
pointer to the new namespace for these sub-subsystems?

cheers,
jamal

