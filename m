From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8132] New: pptp server lockup in   ppp_asynctty_receive()
Date: Fri, 9 Mar 2007 11:21:43 +0100
Message-ID: <20070309102143.GD1662@ff.dom.local>
References: <20070308084539.GA2423@ff.dom.local> <01a001c76226$c956b290$9b01a8c0@Empty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:58088 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2993102AbXCIKRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 05:17:40 -0500
Content-Disposition: inline
In-Reply-To: <01a001c76226$c956b290$9b01a8c0@Empty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 11:40:04AM +0300, Yuriy N. Shkandybin wrote:
...
> I already have
> CONFIG_PROVE_LOCKING=y
> # CONFIG_4KSTACKS is not set
> .config is at
> http://bugzilla.kernel.org/attachment.cgi?id=10660&action=view
> Also all information i've provied was recieved by serial console and it's 
> not hand writing.

Maybe you cut too much (lines before a bug could be meaningful
- if there are some secret data - try to mask only them).
And there is no real lockdep diagnose, so I wasn't sure.
Dump registers at the end looks incomplete (no ESP info), too.
So, this all made me think - it's cut because it's from the screen.
Very sorry!!!

> I've checked logs and right before lockup there is oops in syslog
> Mar  5 21:50:44 vpn2 skb_under_panic: text:c02248a2 len:207 put:1 

As a matter of fact the first bug is the most interesting
and everything after could be only some aftereffect.
This skb_under_panic message could change all diagnose:
it's not necessarily a locking problem.
On the other hand this could be even harder to diagnose
than locking...

> head:db96e22c data:db96e22b tail:db96e2fa end:db96e82c dev:<NULL>
> Mar  5 21:50:44 vpn2 ------------[ cut here ]------------

Why?! We don't even know if there was some config pending here.

> Mar  5 21:50:44 vpn2 kernel BUG at net/core/skbuff.c:112!
...
> Another thing - when i`ve changed HZ from 100 too 300 there is no such 
> lockups for few days.

You wrote it had been since several kernel releases, so it
shouldn't be the case, but anyway - it would be interesting
to check HZ 100 but with clean and more current kernel version
e.g. 2.6.21-rc3.

Thanks & regards,
Jarek P.
