From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Thu, 19 Aug 2010 23:20:19 -0700
Message-ID: <20100819232019.6f6074a8.akpm@linux-foundation.org>
References: <bug-16626-10286@https.bugzilla.kernel.org/>
	<20100819152143.8a57c465.akpm@linux-foundation.org>
	<4C6E0C99.2060407@fs.uni-ruse.bg>
	<20100819221142.b8f6a70a.akpm@linux-foundation.org>
	<4C6E1CBA.2060605@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46286 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959Ab0HTGSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 02:18:42 -0400
In-Reply-To: <4C6E1CBA.2060605@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Aug 2010 09:12:10 +0300 Plamen Petrov <pvp-lsts@fs.uni-ruse.bg> wrote:

> With the "echo 100 > /proc/sys/kernel/printk_delay" command run by
> /etc/rc.d/rc.local, while still on 2.6.36-rc1-00127-g763008c, I got
> these:
> 
> [picture 4]
> http://picpaste.com/aa3e373e894179e8ba19587ed63d8104.jpg

bewdy, thanks.

        BUG_ON(csstart > skb_headlen(skb));

Hopefully that's enough for the net guys to work with.

> [picture 5]
> http://picpaste.com/9bc4bdc04f5a84fdaf49d6e1db23ede8.jpg
> 
> [picture 6]
> http://picpaste.com/da3ccd69a0a1221bb55f48b39c4ad950.jpg
> 
> Hope the above help.
> 
> And by the way, I think you are correct that this is a
> post-2.6.35 thing, because 2.6.35.2 was the first to give
> me this kind of problems, and I can confirm that 2.6.34
> does not have it, because the system was on 2.6.34.4 for
> the last 12 hours without problems, then just a moment ago
> crashed on 2.6.36-rc1-00127-g763008c, and now back on
> 2.6.34.4

OK.

> P.S. Shouldn't "echo 100 > /proc/sys/kernel/printk_delay" be
> somewhere on the "How to debug a crashing kernel guide"
> somewhere?

I only just thought of it ;)

I'm thinking perhaps that we should have a lines_after_oops boot
parameter which makes the console shut up N lines after someone called
oops_enter().

