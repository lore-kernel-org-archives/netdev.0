From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 08:11:21 -0400
Message-ID: <1285243881.5036.22.camel@bigi>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	 <m1bp7oq1u8.fsf@fess.ebiederm.org>  <4C9B162E.7040201@parallels.com>
	 <1285240797.5036.5.camel@bigi>  <4C9B3B06.900@parallels.com>
	 <1285242055.5036.9.camel@bigi>  <4C9B3F9C.8080506@parallels.com>
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
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C9B3F9C.8080506@parallels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 15:53 +0400, Pavel Emelyanov wrote:

> Why does it matter? You told, that the usage scenario was to
> add routes to container. If I do 2 syscalls instead of 1, is
> it THAT worse?
> 

Anything to do with socket IO that requires namespace awareness
applies for usage; it could be tcp/udp/etc socket. If it doesnt
make any difference performance wise using one scheme vs other
to write/read heavy messages then i dont see an issue and socketat
is redundant.

If i was to pick blindly - I would say whatever approach with
less syscalls is better even if just a "slow" path one time
thing. I could create a scenario which would make it bad
to have more syscalls.

But theres also the simplicity aspect in doing:
fdx = socketat namespace foo
use fdx for read/write/poll into foo without any wrapper code.
Vs
enter foo
fdx = socket ..
read/write fdx
leave foo.

> Just like it used to before the enter.
> 

So if i enter foo, get a fdx, leave foo i can use it in
ns0 as if it was in ns0?

cheers,
jamal

