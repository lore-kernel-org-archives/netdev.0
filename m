From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Mon, 22 Feb 2010 16:55:29 -0500
Message-ID: <1266875729.3673.12.camel@bigi>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	 <4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	 <4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	 <m13a0tf17t.fsf@fess.ebiederm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m13a0tf17t.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-02-22 at 12:46 -0800, Eric W. Biederman wrote:
> jamal <hadi@cyberus.ca> writes:

> 
> This is one of the long standing issues that we have always known
> we needed to solve, but have not taken the time to do it.  Now that
> the need is more real it looks about time to solve this one.
> 
> There are currently two problems.
> 1) A process is needed to hold a reference to the network namespace.
> 2) We use pids which are an awkward way of talking about network
>    namespaces.
> 
> The solution I have been playing with involves.
> - Using a file descriptor to refer to a network namespace.
> - Using a trivial virtual filesystem to persistently hold onto
>   a namespace without the need of a process.
> - Have a convention of mounting the fs at something like
>   /var/run/netns/<name>
> 

I didnt quiet follow how i could use the above to do:
"ip ns <name/id> route add blah" from namespace0.

I tend to think in packets and wires instead of files;
How about just allowing a "control" channel from which
i could discover the namespace?
Example, assuming i have the right permissions:
1) listen to async events example on a multicast bus when
a namespace is created or destroyed. Provide me a little more info on
the created namespace such as its pid, name(?), types of namespace, etc
2) send a query to dump existing namespace or query by name, id etc.
I get the same details as above.

using genetlink should provide you with sufficient ability to do this.

cheers,
jamal

