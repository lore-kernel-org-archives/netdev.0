From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] netns: add /proc/*/net/id symlink
Date: Mon, 23 May 2011 03:43:03 +0200
Message-ID: <20110523014303.GA2351982@jupiter.n2.diac24.net>
References: <20110521093936.GA3015@p183>
 <m11uzsxdty.fsf@fess.ebiederm.org>
 <20110521223054.GA3198@p183>
 <m1vcx3r3o5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, equinox@diac24.net,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:37509 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224Ab1EWBnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 21:43:20 -0400
Content-Disposition: inline
In-Reply-To: <m1vcx3r3o5.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ... Eric W. Biederman wrote:
> Now it probably needs to be better documented that /proc/*/net/*
> have the same inode number if the network namespace is the
> same, as everyone including myself overlooked this very handy
> existing property.

Eh, so did I. But, yes, very nice.

On Sat, May 21, 2011 at 05:15:38PM -0700, Eric W. Biederman wrote:
> Additionally that solution will work for comparing network namespaces
> that don't happen to have any processes in them at the moment.  Because
> fstat works on file descriptors.

Hm. I have a peeve here. Assume I am a... rogue admin, whatever. I have
root on a router. I create a new network namespace, put a macvlan of
eth0 in it and a macvlan of eth1. I enable ip_forward.

Then I make a mount namespace, bind-mount the net namespace, bind mount
the mount namespace and terminate all processes that reference it (yes
this does work, i just checked [!]).

Now I can use it to bypass all firewall rules, IDS, whatever.

How is any normal admin, monitoring script or whatever else able to
detect this?

> With the /proc/<pid>/ns/net file and bind mounts I have solved the
> deeper problem of how do we get userspace policy into the naming of
> namespaces.  With those files and the setns system call I have solved
> the other problem of what is a good way to refer to namespaces without
> assuming a global name.  So once those changes are merged I expect there
> to be much less pressure to misuse any kind of identifier we can have.
> 
> And if we only make the guarantee about inode consistency for the
> /proc/<pid>/ns/FILE files I don't expect it will make maintenance
> of procfs any harder than it already is.


-David

