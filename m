From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with 2.6.26-rc5
Date: Sat, 14 Jun 2008 23:45:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806141351500.32523@wrl-59.cs.helsinki.fi>
References: <bug-10903-10286@http.bugzilla.kernel.org/>
 <20080613025804.4913de04.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org,
	didier@raboud.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33689 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbYFNUpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 16:45:45 -0400
In-Reply-To: <20080613025804.4913de04.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jun 2008, Andrew Morton wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 13 Jun 2008 02:39:17 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10903
> > 
> >            Summary: ssh connections hang with 2.6.26-rc5
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.26-rc5
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: acme@ghostprotocols.net
> >         ReportedBy: didier@raboud.com
> > 
> > 
> > Latest working kernel version: 2.6.25-2
> > Earliest failing kernel version: 2.6.26-rc5
> > Distribution: Debian (Lenny + Sid)
> > Hardware Environment: amd64 (Dell Latitude D630)
> > Software Environment: KDE
> > Problem Description:
> > 
> > With kernel version 2.6.26-rc5, the ssh connections to remote servers 
> > randomly 
> > hang (no error message). No amelioration despite the activation of
> > "ServerAliveInterval" on both sides.

Thanks for reporting. Could you please clarify couple of things:

Does this only happen with a particular server/servers?
Any middleboxes in between (NAT, firewall, etc.)?
Do all ssh connections hang simultaneously?
How long have you waited until concluding that TCP is "hung"?
Is TSO enabled (ethtool -k)? Have you tried without it?
It wouldn't hurt to include info about eth hw too (e.g., lspci), though 
it might turn unneeded at some point of time but it might save an email 
round-trip.

TCP can appear to hang due to vast number of reasons. Only recent changes 
that are suspectable is the DEFERRED_ACCEPT thing which is already 
reverted in the very latest Linus' tree (even -rc6 is too old for that) 
and few FRTO fixes (you can exclude FRTO by turning 
/proc/sys/net/ipv4/tcp_frto sysctl to 0 but it seems quite unlikely to 
change anything); your problem might well come from something else and TCP 
hang is just a symptom of other problem downstream.

So please gather this information (at least for the relevant connections):

$ netstat -pn
$ cat /proc/net/tcp

...Also a tcpdump might be handy (though I don't know yet).

...Depending on your privacy needs, you may want obfuscate ip addresses 
that are revealed by all of those logs (ie., if you don't want to reveal 
with whom you're communicating with, ssh payload is encrypted anyway).

> > Steps to reproduce:
> > 
> > Connect to a remote ssh server and do some stuff. After some time, the
> > connection will hang.
> > 
> > Please ask for details.

(I'll be away nearly a month after Tuesday, so I probably won't have much 
time to resolve this issue but I hope I've some time to take a look before 
I leave).

-- 
 i.
