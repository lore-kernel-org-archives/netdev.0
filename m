From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] procfs: add hidepid and hidenet modes
Date: Sun, 12 Jun 2011 16:43:25 +0400
Message-ID: <20110612124324.GA3476@albatros>
References: <20110612075100.GA4459@albatros>
 <20110612111222.GA23467@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Nikanth Karthikesan <knikanth@suse.de>,
	David Rientjes <rientjes@google.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	kernel-hardening@lists.openwall.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64153 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab1FLMqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:46:15 -0400
Content-Disposition: inline
In-Reply-To: <20110612111222.GA23467@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2011 at 14:12 +0300, Alexey Dobriyan wrote:
> On Sun, Jun 12, 2011 at 11:51:01AM +0400, Vasiliy Kulikov wrote:
> > hidenet means /proc/PID/net will be accessible to processes with
> > CAP_NET_ADMIN capability or to members of a special group.
> > 
> > gid=XXX defines a group that will be able to gather all processes' info
> > and network connections info.
> > 
> > Similar features are implemented for old kernels in -ow patches (for
> > Linux 2.2 and 2.4) and for Linux 2.6 in -grsecurity (but both of them
> > are implemented as configure options, not cofigurable in runtime).
> > 
> > 
> > In current version hidenet works for CONFIG_NET_NS=y via creating a
> > "fake" net namespace and slipping it to nonauthorized users, resulting
> > in users observing blank net files (like nobody use the network).  If
> > CONFIG_NET_NS=n I don't see anything better than just fully denying
> > access to /proc/<pid>/net.  More elegant ideas are welcome.
> 
> This fake netns concept is ugly.
> If you wan't deny something, why don't you return -E?

Sorry, I should have mentioned it.  It's a workaround.  The thing is
that /proc/net/* is so core and existed for a long time that some
programs might be confused if these files are missing or if open()
returns -EXXX.  netstat handles this and outputs smth like "Networking
was disabled in your kernel", which is a bit confusing.  Also I saw some
programs didn't handle missing files at all, I recall brctl sigfaulted
when he couldn't access some sysfs file.

As fake_net doesn't break something, but instead keeps some
compatibility with old programs, why don't use it?

BTW, there is no fake_net in -ow or -grsecurity.  I thought it might be
helpful for upstream in sense of compatibility.

> Regardless, these should be separate patch from PID stuff.

No problem.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
