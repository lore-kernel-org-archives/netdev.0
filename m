From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 3 Jun 2010 13:02:35 -0700
Message-ID: <20100603130235.c372b38f.akpm@linux-foundation.org>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55006 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873Ab0FCUCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 16:02:38 -0400
In-Reply-To: <bug-16083-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 May 2010 15:55:12 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16083
> 
>            Summary: swapper: Page allocation failure
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.34
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: sgunderson@bigfoot.com
>         Regression: No
> 
> 
> Hi,
> 
> Since upgrading from a Q9450 to 2xE5520 (and upgrading from 2.6.34-rc-something
> to 2.6.34), I've started seeing these:
> 
> [605882.372418] swapper: page allocation failure. order:2, mode:0x4020
> [605882.378981] Pid: 0, comm: swapper Not tainted 2.6.34 #1
> [605882.384617] Call Trace:
> [605882.387499]  <IRQ>  [<ffffffff81096d5a>] __alloc_pages_nodemask+0x5b0/0x629
> [605882.395068]  [<ffffffff81096de5>] __get_free_pages+0x12/0x4f
> [605882.401103]  [<ffffffff810bdeb4>] __kmalloc_track_caller+0x4c/0x156
> [605882.407817]  [<ffffffff81245986>] ? sock_alloc_send_pskb+0xdd/0x32d
> [605882.414556]  [<ffffffff8124a515>] __alloc_skb+0x66/0x15b

I wonder if we should switch __alloc_skb() over to __GFP_NOWARN. 
People keep on reporting events such as the above, and nobody's
getting any value from this.

Downsides:

- the change would tend to deprive MM developers of prompt "hey you
  broke it again" notifications.

- if a system is getting enough allocation failures to impact
  throughput, the operators won't *know* that it's happening, and so
  they won't make the changes necessary to reduce the frequency of
  memory allocation failures.

If these are likely to be a problem, perhaps networking could provide
some other form of "hey, you keep on running out of memory"
notification, if it doesn't already do so.

Thoughts?

