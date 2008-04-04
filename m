From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 4 Apr 2008 23:43:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804042321520.8186@wrl-59.cs.helsinki.fi>
References: <20080402224137.GB25768@curie-int.orbis-terrarum.net>
 <20080403211913.3a0c1d00.akpm@linux-foundation.org>
 <200804041609.m34G9PPM003350@freevo.ajlc.waterloo.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Tony Lill <ajlill@ajlc.waterloo.on.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39422 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbYDDUnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 16:43:41 -0400
In-Reply-To: <200804041609.m34G9PPM003350@freevo.ajlc.waterloo.on.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2008, Tony Lill wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > (cc netdev)
> >
> > (and Rafael - I assume 2.6.24 didn't do this..)
> >
> > On Wed, 2 Apr 2008 15:41:37 -0700 "Robin H. Johnson" <robbat2@gentoo.org> wrote:
> >
> >> (Please CC, not on LKML).
> >> 
> >> One of the nodes in my web-serving cluster (isohunt.com) started showing this:
> >> 
> >> ------------[ cut here ]------------
> >> WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
> >> Modules linked in: lm85 hwmon_vid nfs lockd nfs_acl sunrpc bonding reiserfs k8temp hwmon i2c_nforce2 i2c_core sg
> >> Pid: 32500, comm: php-cgi Not tainted 2.6.25-rc4-git2 #7
> 
> Are you talking about the warning in this particular module, or
> WARNINGS in tcp_input.c (and tcp_output.c) in general. 'Cause I've
> been getting them sporadically since moving from 2.6.23 to 2.6.24.

2.6.22-2.6.23 did have WARNINGs but BUG_ON but I had to back off from that 
for NewReno case because it was just hitting it because of some 
transitional states (SACK TCP has been under this check since 2.6.22, 
before that it just silently corrected incorrect estimates). For 2.6.24 
the severity was reduced to WARN_ON to avoid crashing people boxes and 
NewReno case was added to the check.

> At least I think that's the timeframe.
> 
> Mar 28 23:42:40 matrix kernel: WARNING: at net/ipv4/tcp_output.c:1799 tcp_simple_retransmit()
> Mar 29 01:03:32 matrix kernel: WARNING: at net/ipv4/tcp_input.c:2413 tcp_fastretrans_alert()
> Mar 29 01:12:41 matrix kernel: WARNING: at net/ipv4/tcp_input.c:1675 tcp_enter_frto()
> Mar 29 03:03:04 matrix kernel: WARNING: at net/ipv4/tcp_input.c:2960 tcp_process_frto()
> Mar 29 03:03:04 matrix kernel: WARNING: at net/ipv4/tcp_input.c:2314 tcp_try_to_open()
> 
> No user visble effects, and no messages since.

In general they're rather harmless (and that combined with the rareness 
of it makes people to not very easily report them), a packet burst in the 
worst case which nobody usually is able to see (if packets_in_flight ends 
up underflowing). Would I not have enabled the tracking, the bugs causing 
them now to show up would never have been detected nor fixed (e.g., the 
tcp_simple_retransmit bug I found yesterday is a long standing one rather 
than regression, also there have been couple of other long standing ones 
found earlier which are nowadays fixed).

-- 
 i.
