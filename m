From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 09:20:17 -0500
Message-ID: <1266934817.3973.654.camel@bigi>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	 <4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	 <4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	 <m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	 <m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	 <m1iq9ocafv.fsf@fess.ebiederm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1iq9ocafv.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added Daniel to the discussion..

On Tue, 2010-02-23 at 06:07 -0800, Eric W. Biederman wrote:
> jamal <hadi@cyberus.ca> writes:

> > Does the point after sys_setns(fd) allow me to do io inside
> > ns <name>? Can i do open() and get a fd from ns <name>?
> 
> Yes.  My intention is that current->nsproxy->net_ns be changed.
> We can already change it in unshare so this is feasible.

I like it if it makes it as easy as it sounds;-> With lxc,
i essentially have to create a proxy process inside the
namespace that i use unix domain to open fds inside the ns.
Do i still need that?

> > The only problem that i see is events are not as nice. I take it i am 
> > going to get something like an inotify when a new namespace is created?
> 
> Yes.  Inotify would at the very least see that mkdir.  You could also
> use poll on /proc/mounts to see the set of mounts change.

It is not as nice but livable. I suppose attributes of the specific
namespace are retrieved somewhere there as well..

> > Is it not just a naming convention that you are dealing with?
> > Example in your scheme above a nested namespace shows up as:
> > /var/run/netns/<name>/<nestedname>, no?
> 
> No.  More like:
> 
> For the outer namespace:
> /var/run/netns/<name>
> 
> For the inner namespace:
> /some/random/fs/path/to/a/chroot/var/run/netns/<name>
> 
> For a doubly nested scenario:
> /some/random/fs/path/to/a/chroot/some/other/random/fs/path/to/another/chroot/var/run/netns/<name>
> 
> Since I would be using mount namespaces instead of chroot it is not
> strictly required that the fs paths nest at all.

Ok.

cheers,
jamal

