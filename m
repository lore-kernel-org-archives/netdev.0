From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [ABI REVIEW][PATCH 0/8] Namespace file descriptors
Date: Thu, 23 Sep 2010 09:32:29 -0700
Message-ID: <m11v8kh142.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<20100923151853.GC1160234@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
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
In-Reply-To: <20100923151853.GC1160234@jupiter.n2.diac24.net> (David
	Lamparter's message of "Thu, 23 Sep 2010 17:18:53 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Lamparter <equinox@diac24.net> writes:

> On Thu, Sep 23, 2010 at 01:45:04AM -0700, Eric W. Biederman wrote:
>> Introduce file for manipulating namespaces and related syscalls.
>> files:
>> /proc/self/ns/<nstype>
>
> As feedback from using network namespaces extensively in more or less
> production setups, I would like to make a request/suggestion: there
> needs to be a way to enumerate network namespaces independent from
> by-pid access.
>
> At several occasions, I was left with either some runaway daemon which
> kept the namespace alive. To describe this a little more graphically:
> I found no other way than doing a
> 	md5sum /proc/*/net/if_inet6 | sort | uniq -c -w 32
> to find out which runaway to kill to terminate the namespace.
>
> This makes network namespaces particularly cumbersome to use without PID
> namespaces. While I agree that a large part of the users - namely lxc -
> will use them together, network namespaces without pidns are very
> interesting for routing applications implementing VRFs.
>
> Is it possible to add some kind of "all namespaces" list, optimally
> giving an opportunity to open() exactly this file descriptor that you
> get from /proc/<pid>/ns/net?
>
> Also, is it possible to extend that file descriptor to have an
> "get all pids" ioctl,
> ...or, wait, maybe have /proc/...ns/proc/<pid> symlink?
>
> (This obviously isn't fully thought to the end, please pick up...)

Maybe.  I can understand the pain.

Is the problem you are facing you are shutting down a vrf and you want
to make certain nothing is using it any longer?

Eric
