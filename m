From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 21:37:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
 <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi> <484191BD.8000904@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1135271880-1212259064=:2672"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?B?SMOla29uIEzDuHZkYWw=?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbYEaSiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 14:38:06 -0400
In-Reply-To: <484191BD.8000904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1135271880-1212259064=:2672
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 31 May 2008, Håkon Løvdal wrote:

> Ilpo Järvinen wrote:
> > Hmm, are the other end's processes still there? ...I'd be interested to know
> > what they're doing at the moment...
> 
> > I meant that end where you see this '-'. I suppose it's easy for you to
> > figure out which process is the right one, something that wouldn't be so
> > easy with the Ingo's test case which forks/exits numerous times.
> 
> > Died? Do you mean that they don't exist all at the other end anymore?

Ok, like you said, this is not exactly the same, though it might be due to 
the same bug. In Ingo's case both endpoints were doing pretty healtily, 
with periodic window probes as expected. In your case TCP is not doing 
window probes but got that interesting RTO value.

So you had that '-' earlier and you checked at that time but the 
connection is now already dead?

> The ssh connection used for copying (using the command <ssh old_pc "cd
> /directory; tar cvf - *" | pv | tar xvf ->) died in the following way:
>   ...
>   Read from remote host old_pc: Connection timed out
>   51.4GB 4:26:19 [3.29MB/s] [<=>                                   ]
>   tar: Unexpected EOF in archive
>   tar: Unexpected EOF in archive
>   tar: Error is not recoverable: exiting now
> 
> and there are currently no traces of those ssh processes any longer on
> the new PC, only these two active ssh interactive connections are present:

:-(, I would some much liked to see what they were doing.

> old_pc>sed -n '1p; /:0016/p' /proc/net/tcp
> sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt
> uid  timeout inode
> 12: 00000000:0016 00000000:0000 0A 00000000:00000000 00:00000000 00000000
> 0        0 7627 1 f384b080 3000 0 0 2 -1
> 17: 111111AC:0016 480111AC:CDBB 01 00000000:00000000 02:0001AA7B 00000000
> 0        0 1110320 2 f02e6580 201 53 7 3 -1
> 20: 111111AC:0016 480111AC:AB31 01 00000000:00000000 02:000A18F1 00000000
> 0        0 583506 4 f71a8080 201 40 29 3 -1
> 21: 111111AC:0016 480111AC:E4E9 01 00000B50:00000000 01:7D1F8746 00000000
> 0        0 398713 5 f71a8580 205 40 1 36 -1
> 23: 111111AC:0016 480111AC:D359 01 000010F8:00000000 01:7D19A035 00000000
> 0        0 396426 5 f71a8a80 202 42 1 144 -1
> 25: 111111AC:0016 480111AC:8565 01 00000B50:00000000 01:7CEBA7D1 00000000
> 0        0 349113 5 eeeaf580 204 40 1 26 -1
> old_pc>

These 7C/D... certainly seem strange values. Which TCP variant you have in 
use (cat /proc/sys/net/ipv4/tcp_congestion_control)? It seems that vegas, 
veno and yeah at least contain 0x7fffffff there for some rtt, which could 
perhaps somehow leak.

-- 
 i.
---696208474-1135271880-1212259064=:2672--
