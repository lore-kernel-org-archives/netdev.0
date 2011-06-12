From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC] procfs: add hidepid and hidenet modes
Date: Sun, 12 Jun 2011 14:12:23 +0300
Message-ID: <20110612111222.GA23467@p183.telecom.by>
References: <20110612075100.GA4459@albatros>
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
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53763 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab1FLLM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 07:12:29 -0400
Content-Disposition: inline
In-Reply-To: <20110612075100.GA4459@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2011 at 11:51:01AM +0400, Vasiliy Kulikov wrote:
> hidenet means /proc/PID/net will be accessible to processes with
> CAP_NET_ADMIN capability or to members of a special group.
> 
> gid=XXX defines a group that will be able to gather all processes' info
> and network connections info.
> 
> Similar features are implemented for old kernels in -ow patches (for
> Linux 2.2 and 2.4) and for Linux 2.6 in -grsecurity (but both of them
> are implemented as configure options, not cofigurable in runtime).
> 
> 
> In current version hidenet works for CONFIG_NET_NS=y via creating a
> "fake" net namespace and slipping it to nonauthorized users, resulting
> in users observing blank net files (like nobody use the network).  If
> CONFIG_NET_NS=n I don't see anything better than just fully denying
> access to /proc/<pid>/net.  More elegant ideas are welcome.

This fake netns concept is ugly.
If you wan't deny something, why don't you return -E?

Regardless, these should be separate patch from PID stuff.
