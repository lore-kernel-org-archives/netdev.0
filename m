From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Sat, 26 Apr 2008 20:31:30 +0400
Message-ID: <20080426163130.GA4499@2ka.mipt.ru>
References: <bug-10556-10286@http.bugzilla.kernel.org/> <20080426040452.4fcbc962.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	ja@ssi.bg, bugme-daemon@bugzilla.kernel.org, l0op8ack@hotmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54475 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753909AbYDZQcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 12:32:13 -0400
Content-Disposition: inline
In-Reply-To: <20080426040452.4fcbc962.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sat, Apr 26, 2008 at 04:04:52AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
>  [<c011c53a>] default_wake_function+0x0/0x8
>  [<c0305c85>] sync_thread+0x0/0xa3c
>  [<c0104aa7>] kernel_thread_helper+0x7/0x10
>  =======================
> Code: a1 20 64 3e c0 89 43 54 8b 54 24 34 0f b7 42 16 66 c1 c0 08 0f b7 c0 66
> 89 43 42 0f b6 42 01 e8 90 06 00 00 0f b7 53 42 0f b7 d2 <8b> 40 14 8b 04 90 89
> 43 38 89 d8 e8 8a 8e ff ff 8b 44 24 28 03 
> EIP: [<c030659e>] sync_thread+0x919/0xa3c SS:ESP 0068:f699bf54
> Kernel panic - not syncing: Fatal exception in interrupt

Any chance to run

gdb ./vmlinux
$ l *(sync_thread+0x919)

for that kernel, and if it was not compiled with debug info try to do
that and get bug with it?
 
> Which will be a bit hard to track down because it seems that pretty much
> the whole world got inlined into sync_thread().

I'm not ipvs guru, but that will give us at least some hint...

-- 
	Evgeniy Polyakov
