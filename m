From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Fri, 23 May 2008 13:25:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805231302410.16829@wrl-59.cs.helsinki.fi>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
 <20080521105747.215be17d.akpm@linux-foundation.org>
 <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
 <Pine.LNX.4.64.0805212310050.7747@wrl-59.cs.helsinki.fi>
 <cf4145200805211345y3b00d209o58e11a7b553cdfc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-123616755-1211537630=:16829"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Brian Vowell <brian.vowell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36399 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750700AbYEWKZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 06:25:27 -0400
In-Reply-To: <cf4145200805211345y3b00d209o58e11a7b553cdfc6@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0805231314400.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-123616755-1211537630=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805231314401.16829@wrl-59.cs.helsinki.fi>

On Wed, 21 May 2008, Brian Vowell wrote:

> On 5/21/08, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > On Wed, 21 May 2008, Brian Vowell wrote:
> >
> > ...This TCP warning isn't sign of a problem that would cause corruption of
> > any kind (and the state inconsistency gets repaired there as well!), we're
> > debugging this already with couple of other people, so unless you have
> > some very good reproducer case you'll just have to wait a bit.
> 
> I don't mind waiting.  I just thought that since this happened so quickly
> after upgrading to the 2.6.25.4 kernel that it might be something that was
> related to changes from 2.6.25.3.

It's just due to luck (that's what makes debugging it hard). There isn't 
anything even remotely related changed in 2.6.25.3 -> 2.6.25.4 :-). Of 
course, if you really want to you can always add the debug patch the other 
2539-warning tracking people already use:

  http://marc.info/?l=linux-netdev&m=120972551120080&w=2

It will add some expensive verifications that are run multiple times per 
ACK to validate TCP's internal consistency which is normally just 
"assumed" to be valid due to performance reasons. Please note what I said 
about CONFIG_LOG_BUF_SHIFT there so that the previous disaster doesn't 
repeat itself... :-) Then you just need to occassionally see if it has 
triggered (from kernel logs).

> The only thing that I can do in regards to assisting is to provide info
> about what triggers the bug and/or provide access to my system to anyone who
> wants to take a closer look.
>
> At the time the bug occurred, the system was running two I/O intensive
> applications.  The first was the "xfs_fsr" tool to defragment the XFS
> filesystem (it was pushing about 25-30MB/sec to the array), and the rtorrent
> BitTorrent client, which was pulling down a Fedora ISO at about 25mbps, and
> writing to a SATA device, separate from the array where the XFS filesystem
> lives.  In the past, I have seen the rtorrent client create oops errors when
> running within a Xen VM.  This problem only occurred when the guest domU VM
> was running XFS for its root filesystem and the host dom0 that provided the
> filestore for the gues was also running XFS.  (Running the guest on ext3
> stops the oops errors).  It may or may not be related to this error that I'm
> reporting, but considering that the rtorrent app is the same app that was
> running at the time of both segfaults and the oops errors, it makes me
> suspicious and I thought that I'd mention it.

All other details but torrent are most likely irrelevant, it could be 
that the added load has some significance to window behavior but that's 
not too likely to make difference. More important would be to know with 
which host torrent was communicating at the time of the WARNING, and even 
more importantly, what "special" happened between that host and your host 
in the network. Once that becomes known thing, this will be easy to 
reproduce and it might even be that the fix is then something dead 
obvious.

> Just to be clear, the bug that I'm reporting is running on a clean system,
> with no Xen installed on it.
> 
> Otherwise, it's really like a bug in real life-- a small creature that is
> annoying but doesn't really harm anything.

The thing I'm still concerned in this report is the presence of the other 
stacktrace which seemed to not be TCP related. Could you confirm/list all 
the other problems than the WARNING net/ipv4/tcp_input.c:2539(+its 
stacktrace) that you have been seeing. ...I'm saying this because it might 
be worth of pursuing further.

-- 
 i.
---696208474-123616755-1211537630=:16829--
