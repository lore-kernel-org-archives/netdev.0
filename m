From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 29252] New: IPv6 doesn't work in a kvm guest.
Date: Thu, 17 Feb 2011 14:25:17 -0800
Message-ID: <20110217142517.b9919481.akpm@linux-foundation.org>
References: <bug-29252-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	David Miller <davem@davemloft.net>, slash@ac.auone-net.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45665 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753176Ab1BQWZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:25:50 -0500
In-Reply-To: <bug-29252-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 16 Feb 2011 13:03:15 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=29252
> 
>            Summary: IPv6 doesn't work in a kvm guest.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38-rc5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: slash@ac.auone-net.jp
>         Regression: Yes
> 
> 
> apt-get and ping6 don't work in a kvm guest. It appears that neighbor discovery
> is not working. I'm using tap, virtio-net and vhost. I did bisect and results
> is
> 
> d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4 is the first bad commit
> commit d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Jan 24 16:01:58 2011 -0800
> 
>     ipv6: Always clone offlink routes.
> 
>     Do not handle PMTU vs. route lookup creation any differently
>     wrt. offlink routes, always clone them.
> 
>     Reported-by: PK <runningdoglackey@yahoo.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> :040000 040000
> c4a34e9e36bd8cc81e898738f2d4344f6647d472f0fcd4b093ec22784798f3951203391f4567b278
> M      net
> 
> reverting this commit for guest kernel fixes the probrem.
> 

