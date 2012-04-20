From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 04/19] net: Kill register_sysctl_rotable
Date: Fri, 20 Apr 2012 07:42:07 -0700
Message-ID: <m1hawe79ds.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
	<m1obqngvcg.fsf@fess.ebiederm.org>
	<20120420135323.GA4877@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33088 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756767Ab2DTOiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 10:38:09 -0400
In-Reply-To: <20120420135323.GA4877@mail.hallyn.com> (Serge E. Hallyn's
	message of "Fri, 20 Apr 2012 13:53:23 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serge@hallyn.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> 
>> register_sysctl_rotable never caught on as an interesting way to
>> register sysctls.  My take on the situation is that what we want are
>> sysctls that we can only see in the initial network namespace.  What we
>> have implemented with register_sysctl_rotable are sysctls that we can
>> see in all of the network namespaces and can only change in the initial
>> network namespace.
>> 
>> That is a very silly way to go.  Just register the network sysctls
>> in the initial network namespace and we don't have any weird special
>> cases to deal with.
>> 
>> The sysctls affected are:
>> /proc/sys/net/ipv4/ipfrag_secret_interval
>> /proc/sys/net/ipv4/ipfrag_max_dist
>> /proc/sys/net/ipv6/ip6frag_secret_interval
>> /proc/sys/net/ipv6/mld_max_msf
>> 
>> I really don't expect anyone will miss them if they can't read them in a
>> child user namespace.
>
> If there was something userspace could do to work around certain values
> of these settings then I'd say keeping the readonly values is worthwhile,
> but AFAICS if a bad network context requires ipfrag_max_dist 0, there's
> nothing userspace can do about it...
>
>
> So from a container pov view at least, I'm happy with this.  I'm far from
> qualified on the netns code itself, but taking a look in the unlikely case
> I can spot something :)

In this case I figured I would copy you and a few others who have been
talking about similar things recently, and also because you might care
that a whole bunch of networking sysctls that aren't per network
namespace will stop showing up in containers.

It is my hope that we use some of these same mechanisms that allow per
network namespace sysctls will be used to allow per pid and uts
namespace sysctls as well.  It isn't as important as the files don't
change, but we can do it cleanly and one of these days I will get around
to making /proc/sys a symlink to /proc/<pid>/sys so that I can remove
the very unorthodox d_compare tricks that we use today.

The sysctl internal data structures are now a hair cleaner than what
sysfs uses for the same class of problem so I might someday go back and
fix sysfs to use the same idea of internal links, so I can get the sysfs
dirent size down some more, and be able to more cleanly isolate the
namespace handling from the rest of the sysfs code.  It isn't bad today
but it is the source of most of the surprises and bugs when people tweak
the sysfs code.

Anyway I ramble.  Now I need to get back to your review comments on my
user namespace patchset.

Thanks for taking a glance here,
Eric
