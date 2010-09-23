From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Thu, 23 Sep 2010 08:14:50 -0700
Message-ID: <m139t0jxud.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<m1hbhgq1v1.fsf@fess.ebiederm.org> <1285240926.5036.7.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
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
To: hadi@cyberus.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285240926.5036.7.camel@bigi> (jamal's message of "Thu, 23 Sep
	2010 07:22:06 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

> On Thu, 2010-09-23 at 01:51 -0700, Eric W. Biederman wrote:
>> Take advantage of the new abstraction and allow network devices
>> to be placed in any network namespace that we have a fd to talk
>> about.
>> 
>
> So ... why just netdevice? could you allow migration of other
> net "items" eg a route table since they are all tagged by
> netns?

For this patchset because we only support migrating physical
network devices between network namespaces today.

In the bigger picture migrating things between network namespaces is
race prone.  Fixing those races probably would reduce network stack
performance and increase code complexity for not particularly good
reason.  Network devices are special because they are physical hardware
and in combination with the rule that all packets coming a network
device go to a single network namespace we have to implement migration
for network devices.

Eric
