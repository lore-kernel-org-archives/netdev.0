From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with 2.6.26-rc5
Date: Mon, 16 Jun 2008 16:21:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806161542290.16829@wrl-59.cs.helsinki.fi>
References: <bug-10903-10286@http.bugzilla.kernel.org/>
 <20080613025804.4913de04.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0806141351500.32523@wrl-59.cs.helsinki.fi>
 <200806151537.11986.didier@raboud.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="Boundary-01=_FsRVI9wgFKqiPJV"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Didier Raboud <didier@raboud.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47957 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbYFPNV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 09:21:29 -0400
In-Reply-To: <200806151537.11986.didier@raboud.com>
Content-ID: <Pine.LNX.4.64.0806161542291.16829@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Boundary-01=_FsRVI9wgFKqiPJV
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806161542292.16829@wrl-59.cs.helsinki.fi>
Content-Disposition: inline

On Sun, 15 Jun 2008, Didier Raboud wrote:

> Le samedi 14 juin 2008 22:45:41 Ilpo Järvinen, vous avez écrit :
> > On Fri, 13 Jun 2008, Andrew Morton wrote:
> > > (switched to email.  Please respond via emailed reply-to-all, not via the
> > > bugzilla web interface).
> 
> OK.
> 
> > > On Fri, 13 Jun 2008 02:39:17 -0700 (PDT) bugme-daemon@bugzilla.kernel.org 
> wrote:
> > > > http://bugzilla.kernel.org/show_bug.cgi?id=10903
> > > >
> > > >            Summary: ssh connections hang with 2.6.26-rc5
> > > >            Product: Networking
> > > >            Version: 2.5
> > > >      KernelVersion: 2.6.26-rc5
> > > >           Platform: All
> > > >         OS/Version: Linux
> > > >               Tree: Mainline
> > > >             Status: NEW
> > > >           Severity: normal
> > > >           Priority: P1
> > > >          Component: Other
> > > >         AssignedTo: acme@ghostprotocols.net
> > > >         ReportedBy: didier@raboud.com
> > > >
> > > >
> > > > Latest working kernel version: 2.6.25-2
> > > > Earliest failing kernel version: 2.6.26-rc5
> > > > Distribution: Debian (Lenny + Sid)
> > > > Hardware Environment: amd64 (Dell Latitude D630)
> > > > Software Environment: KDE
> > > > Problem Description:
> > > >
> > > > With kernel version 2.6.26-rc5, the ssh connections to remote servers
> > > > randomly
> > > > hang (no error message). No amelioration despite the activation of
> > > > "ServerAliveInterval" on both sides.
> >
> > Thanks for reporting. Could you please clarify couple of things:
> 
> Hi.
> 
> I will try to, with my time and knowledge.
> 
> > Does this only happen with a particular server/servers?
> 
> I have only tried with two of my home servers. One runs 2.6.22-4-686 and the 
> other 2.6.18-6-vserver-686.
> 
> > Any middleboxes in between (NAT, firewall, etc.)?
> 
> There is a ADSL router which "provides" internet to the servers by NAT. 
> I have  tried from "inside" the house (so in the same subnet) and from 
> outside: it hangs in both cases.

...Ok. Those have some timeouts for idle sessions, so if one has active or 
keepalived sessions that shouldn't be a problem.

> The common point is my use of "iwl3945" : I have always tried the ssh 
> connections through WiFi.
>
> > Do all ssh connections hang simultaneously?
> 
> Well... It is hard to say. As far as I have seen, no. When I get one hang, I 
> can successfully connect to the same server.

It's quite likely that the hangs are independent, but it was worth of 
confirming still.

> > How long have you waited until concluding that TCP is "hung"?
> 
> Well. The "ServerAliveInterval" option of openssh now leads to "Received 
> disconnect from $IP: 2: Timeout, your session not responding." after the 
> hang. So the openssh server notices that my session is not responding and so 
> cuts the connection.
>
> > Is TSO enabled (ethtool -k)? Have you tried without it?
> 
> Doesn't seem:
> 
> ----
> # ethtool -k wlan0
> Offload parameters for wlan0:
> Cannot get device rx csum settings: Operation not supported
> Cannot get device tx csum settings: Operation not supported
> Cannot get device scatter-gather settings: Operation not supported
> Cannot get device tcp segmentation offload settings: Operation not supported
> Cannot get device udp large send offload settings: Operation not supported
> Cannot get device generic segmentation offload settings: Operation not 
> supported
> no offload info available
> ----
>
> > It wouldn't hurt to include info about eth hw too (e.g., lspci), though
> > it might turn unneeded at some point of time but it might save an email
> > round-trip.
> 
> lspci attached.

...Thanks for all the details. I especially appreciated the kernel 
versions of the servers since TCP has two end hosts (and I forgot to 
ask)... :-)

> > TCP can appear to hang due to vast number of reasons. Only recent changes
> > that are suspectable is the DEFERRED_ACCEPT thing which is already
> > reverted in the very latest Linus' tree (even -rc6 is too old for that)
> > and few FRTO fixes (you can exclude FRTO by turning
> > /proc/sys/net/ipv4/tcp_frto sysctl to 0 but it seems quite unlikely to
> > change anything); your problem might well come from something else and TCP
> > hang is just a symptom of other problem downstream.
> 
> I can't understand everything, but what I can say is that with the exact 
> same software, I get no hangs  with 2.6.25-2 but I get some with 
> 2.6.26-rc5.

Yes, I understand that... I was just trying to bring up above what has 
changed between those kernels :-). ...Quite few TCP related changes 
actually (there were also some TSO related changes but they're not 
significant in your case).

> > So please gather this information (at least for the relevant connections):
> >
> > $ netstat -pn
> > $ cat /proc/net/tcp
> 
> Attached.

I probably wasn't specific enough. ...I meant that you would get this once 
one of the ssh sessions gets stuck (do it right after you notice that the 
session is stuck, that should get the info before the connection is cut 
down). This info should be collected from both ends (on client and 
server).

> > ...Also a tcpdump might be handy (though I don't know yet).
> 
> Well. It seems that there is another bug here: everytime I tried a

Ah, lets try to figure that one out as well...

> # tcpdump -w /tmp/tcpdump.wlan0 -i wlan0
>
> I got a CPU lockup (or similar, can't know exactly, but keyboard blocked and 
> nothing doable).

You probably run it under X, no? Please switch beforehand to some other vt 
(a textual one) then (Ctrl-Alt-Fn, where n < 6) and then log in and 
running that command there and see if you get some output into screen 
there. If you see something (e.g., a sudden OOPS message or some other 
warning printed) when it locks up, the easiest things is to take a shot 
with a digicam (or write it down somewhere else) and send that shot (or 
those details) to us please.

...Once you have a tcpdump, I can probably figure at least something out 
(though it might still just point to the right direction rather than 
exposing the actual cause).

-- 
 i.
--Boundary-01=_FsRVI9wgFKqiPJV--
