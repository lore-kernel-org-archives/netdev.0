From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH urgent] netlink: Only check file credentials for
 implicit destinations
Date: Mon, 02 Jun 2014 16:34:51 -0700 (PDT)
Message-ID: <20140602.163451.2020310558428252845.davem@davemloft.net>
References: <06bbac8182aa1054ab8f6392f14e9148def0f561.1401472882.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, security@kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jorge@dti2.net, jbenc@redhat.com,
	vgoyal@redhat.com, ssorce@redhat.com, serge@hallyn.com
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaFBXew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:34:52 -0400
In-Reply-To: <06bbac8182aa1054ab8f6392f14e9148def0f561.1401472882.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 30 May 2014 11:04:00 -0700

> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> It was possible to get a setuid root or setcap executable to write to
> it's stdout or stderr (which has been set made a netlink socket) and
> inadvertently reconfigure the networking stack.
> 
> To prevent this we check that both the creator of the socket and
> the currentl applications has permission to reconfigure the network
> stack.
> 
> Unfortunately this breaks Zebra which always uses sendto/sendmsg
> and creates it's socket without any privileges.
> 
> To keep Zebra working don't bother checking if the creator of the
> socket has privilege when a destination address is specified.  Instead
> rely exclusively on the privileges of the sender of the socket.
> 
> Note from Andy: This is exactly Eric's code except for some comment
> clarifications and formatting fixes.  Neither I nor, I think, anyone
> else is thrilled with this approach, but I'm hesitant to wait on a
> better fix since 3.15 is almost here.
> 
> Note to stable maintainers: This is a mess.  An earlier series of
> patches in 3.15 fix a rather serious security issue (CVE-2014-0181),
> but they did so in a way that breaks Zebra.  The offending series
> includes:
> 
>     commit aa4cf9452f469f16cea8c96283b641b4576d4a7b
>     Author: Eric W. Biederman <ebiederm@xmission.com>
>     Date:   Wed Apr 23 14:28:03 2014 -0700
> 
>         net: Add variants of capable for use on netlink messages
> 
> If a given kernel version is missing that series of fixes, it's
> probably worth backporting it and this patch.  if that series is
> present, then this fix is critical if you care about Zebra.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Applied, thanks Andy.
