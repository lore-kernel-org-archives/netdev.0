From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: /proc/net/ bad hard links count [Was: 2.6.23-rc8-mm2]
Date: Fri, 28 Sep 2007 11:03:26 -0600
Message-ID: <m1tzpebu3l.fsf@ebiederm.dsl.xmission.com>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
	<46FD2C10.8050105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35859 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbXI1REA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 13:04:00 -0400
In-Reply-To: <46FD2C10.8050105@gmail.com> (Jiri Slaby's message of "Fri, 28
	Sep 2007 18:30:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby <jirislaby@gmail.com> writes:

> On 09/27/2007 11:22 AM, Andrew Morton wrote:
>>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc8/2.6.23-rc8-mm2/

Yep.

> # find /proc >/dev/null
> find: WARNING: Hard link count is wrong for /proc/net: this may be a bug in your
> filesystem driver.  Automatically turning on find's -noleaf option.  Earlier
> results may have failed to include directories that should have been searched.
> # stat net
>   File: `net'
>   Size: 0               Blocks: 0          IO Block: 1024   directory
> Device: 3h/3d   Inode: 4026531864  Links: 2
> Access: (0555/dr-xr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
> Access: 2007-09-28 18:21:24.651209759 +0200
> Modify: 2007-09-28 18:21:24.651209759 +0200
> Change: 2007-09-28 18:21:24.651209759 +0200
> # stat net/
>   File: `net/'
>   Size: 0               Blocks: 0          IO Block: 1024   directory
> Device: 3h/3d   Inode: 4026531909  Links: 4
> Access: (0555/dr-xr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
> Access: 2007-09-28 18:26:48.813048220 +0200
> Modify: 2007-09-28 18:26:48.813048220 +0200
> Change: 2007-09-28 18:26:48.813048220 +0200
>
> hmm, this is some kind of weirdness :)

Yes.

I can explain it. For the network namespace stuff we need special handling
of /proc/net so that depending on the network namespace we are resolving
against you see a different behavior.  So you actually are observing
two different directories, one being a magic invisible symlink to the
other.

Currently I am resolving against current (which has a number of
limitations) and the weird ugly effect you are current seeing.

So it looks like I need to either make /proc/net a symlink to
/proc/self/net or make the network namespace something that we capture
at mount time of /proc.

This was my don't get hung up on this implementation detail version.
Thanks for pointing out it has user visible problems.  I will see
what I can do to resolve this.

Eric
