From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 4 Jun 2008 14:14:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
  <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>  <484191BD.8000904@gmail.com>
  <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
 <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-565432715-1212578046=:16829"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59308 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbYFDLOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 07:14:10 -0400
In-Reply-To: <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-565432715-1212578046=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 4 Jun 2008, Håkon Løvdal wrote:

> Hi. I have now tested and taken various logs before/under/after (ps, 
> netstat, tcpdump, strace, /proc/net/tcp). The logs did not grow as big 
> as I feared however they are way too big attach here. Any tips on how to 
> distribute?

Usually such logs compress quite well. A best thing might be to put 
somewhere (if possible) and http:// reference them.

> I mentioned before that the ssh connection died on the new PC, but 
> sometimes it just hangs as well, i.e. the ssh connection is alive but 
> there is no data transferred.
> The last test I did hang after just 292MB transferred. In this case pv
> just hangs on the new PC, waiting for data that never arrives. On the 
> sending side tar which is producing data have died and the corresponding 
> ssh is locked in some uninterruptible sleep:

> //netstat before the hang:
> Proto Recv-Q Send-Q Local Address               Foreign Address
>      State       PID/Program name    Timer
> tcp        0    504 new_pc:22                   old_pc:39464
>      ESTABLISHED 17054/sshd: hlovdal on (0.20/0/0)
> 
> // after the hang:
> Proto Recv-Q Send-Q Local Address               Foreign Address
>      State       PID/Program name    Timer
> tcp        0   2896 old_pc:22                   new_pc:39464
>      ESTABLISHED -                   on (21329441.19/0/0)

??? Are these on the same machine? How come the ip-addresses got reversed 
(while ports remain the same)...?!?

...Something could be corrupting more than a little, addresses, reference 
to the process, timers all seem mixed up here...

> Many things  in /proc/17054/ are in a non-normal state (exe is an
> empty symlink, fd is empty, etc)

...


-- 
 i.
---696208474-565432715-1212578046=:16829--
