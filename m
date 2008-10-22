From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net
	device sysfs entries
Date: Wed, 22 Oct 2008 15:30:45 -0500
Message-ID: <20081022203045.GA4633@us.ibm.com>
References: <20081022152144.351965414@theryb.frec.bull.fr> <m1d4hso0ym.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:35772 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbYJVUa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 16:30:56 -0400
Content-Disposition: inline
In-Reply-To: <m1d4hso0ym.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Benjamin Thery <benjamin.thery@bull.net> writes:
> 
> > Support for network namespaces in mainline is pretty complete for
> > some time now, but there is still this issue with sysfs that prevents 
> > more people to use it easily.
> 
> Ben your patchset is completely inappropriate.
> 
> Temporarily adding elements to the ABI that we intend to remove
> is not a proper solution to this problem.
> 
> That user space visible ida you add is a namespace identifier that breaks
> nested containers and migration.  It is very very very wrong.

I disagree (not surprising :) completely.  The well-known userspace
tools (ifconfig, ip, etc) will not see the lo@1, they'll see lo.
Userspace in a container can either umount /sys completely, or do

	mount -t tmpfs none /sys/class/net
	mount --bind /sys/devices/virtual/net/lo@1 /sys/class/net/lo

if they really want to, in which case only their view
of /sys/devices/virtual/net would be different.

Eric, would you hate this less if it was under some

	CONFIG_SYSFS_NETNS_HACK

config variable?

-serge
