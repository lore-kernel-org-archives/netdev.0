From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Mon, 22 Feb 2010 12:46:14 -0800
Message-ID: <m13a0tf17t.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: hadi@cyberus.ca
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1263568754.23480.142.camel@bigi> (jamal's message of "Fri\, 15 Jan 2010 10\:19\:14 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

>> > Agreed. But the major ones like iproute2 etc could be taught. We have
>> > namespaces in the kernel already, over a period of time I think changing
>> > the user space tools would a sensible evolution.
>> 
>> Yes, that might be useful in any case. But I don't think it would
>> even work for iproute or other standalone programs, a process can't
>> associate to an existing namespace except through clone(). So it
>> needs to run as child of a process already associated with the
>> namespace.
>
> The mechanics are not there, yet. But if i had sufficient permission,
> and was able to find the namespaces when i ask and/or get events when it
> is created it should be an issue of sending it a message.
> The current approach to say migrate a veth via iproute2 requires we 
> know the pid of the target namespace. Thats a usability issue.
> I tried to muck with namespaces and if you use a library like lxc
> you can do it - but it is a hack as it stands today (and merging
> iproute2 with lxc is questionable).

This is one of the long standing issues that we have always known
we needed to solve, but have not taken the time to do it.  Now that
the need is more real it looks about time to solve this one.

There are currently two problems.
1) A process is needed to hold a reference to the network namespace.
2) We use pids which are an awkward way of talking about network
   namespaces.

The solution I have been playing with involves.
- Using a file descriptor to refer to a network namespace.
- Using a trivial virtual filesystem to persistently hold onto
  a namespace without the need of a process.
- Have a convention of mounting the fs at something like
  /var/run/netns/<name>

That solves the naming problem, and it should allow iproute and
it's kin to have support without being closely integrated with
lxc or anything else that creates namespaces.

It is a big conversation, and it is something that has to done
right but it looks like the problem is finally real enough that
it is time to solve it.

Eric
