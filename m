From: Alan Cox <alan@linux.intel.com>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 11:41:11 +0100
Message-ID: <20090916114111.2228f0fc@linux.intel.com>
References: <20090911212731.GA19901@shareable.org>
	<1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	<20090912094110.GB24709@ioremap.net>
	<20090914001759.GB30621@shareable.org>
	<20090914140720.GA8564@ioremap.net>
	<1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
	<20090915201620.GB32192@ioremap.net>
	<1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
	<alpine.LFD.2.01.0909151643540.4950@localhost.localdomain>
	<1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com>
	<20090916075219.GA22024@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:43639 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751847AbZIPKqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 06:46:50 -0400
In-Reply-To: <20090916075219.GA22024@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - fanotify does not provide subtree notification in it's
>   present form.  When it is extended to do that, why wouldn't
>   inotify be as well?  That's an fsnotify feature, common to both.

Because inotify gives you no reliable access to the object monitored as
the name passed back is not an object reference and is racy. Inotify is
fine for making pretty icons pop up on desktops and making file
selectors update, but it is somewhat inadequate for indexers and
completely useless for stuff like HSM.

> - fanotify requires you call readlink(/proc/fd/N) for every event to
>   get the path.  It's not a particularly efficient way to get it,

IFF you want the path, but the path isn't usually the most valuable bit.
Plus you'll find the readlink is extremely quick anyway.

> People who want to break out of chroot/namespace jails using the
> conveniently provided open file descriptor? :-)

chroot isn't a security model. You can already do this with AF_UNIX
sockets (and there are apps that intentionally use fchdir that way)

> I'd expect anti-malware to want to be run inside VMs quite often...

Inside of containers - unlikely. Inside of guests sure but thats not
going to relevant to fanotify()

> the accessing process until acked), that's ok with me.  It makes
> sense.  But then it's messy that neither offers a superset of the
> other regarding which files and events are tracked.

Agreed.

