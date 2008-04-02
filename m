From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc6-git2: warn_on_slowpath for tcp_simple_retransmit
Date: Wed, 2 Apr 2008 23:39:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804022333230.10610@wrl-59.cs.helsinki.fi>
References: <5a4c581d0804011528g786550c5sfd6bf90c0c37706@mail.gmail.com>
 <Pine.LNX.4.64.0804021110190.10371@wrl-59.cs.helsinki.fi>
 <5a4c581d0804021309y6b0f3af1tab24090a17104bf4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1168032753-1207168751=:10610"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35916 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764010AbYDBUjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:39:14 -0400
In-Reply-To: <5a4c581d0804021309y6b0f3af1tab24090a17104bf4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1168032753-1207168751=:10610
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 2 Apr 2008, Alessandro Suardi wrote:

> On Wed, Apr 2, 2008 at 10:10 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> > On Wed, 2 Apr 2008, Alessandro Suardi wrote:
> >
> >  > Found this in my FC6-based bittorrent box (K7-800 running
> >  >  a 2.6.25-rc6-git2 kernel) this evening.
> >  >
> >  > The kernel was upgraded two weeks ago to fix the bug
> >  >  in which an USB VIA driver hammered the PCI bus
> >  >  causing ATA disk performance to drop, and has been
> >  >  running since then (it still is).
> >  >
> >  > So it's actually 2.6.25-rc6-git2 plus patch as in here
> >  > http://www.gossamer-threads.com/lists/linux/kernel/895506#895506
> >  >
> >  > If there's anything useful I can do, just ask. Thanks !
> >
> >  Can you reproduce?
> 
> Nope. That only happened once in this uptime:
> 
> [root@donkey ~]# uptime
>  21:57:21 up 14 days, 22:04,  5 users,  load average: 0.64, 0.47, 0.44
> 
> The machine runs unattended as a bittorrent client, 24x7,
>  with a very low traffic (uploading at a steady ~36KB/s,
>  and downloads happen in peaks).
> 
> I VNC into it in the evening and manage the torrents;
>  that is all.
> 
> Now, there's an interesting tidbit:
> 
> [root@donkey ~]# ip -s link show eth0
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 00:c0:49:a7:33:fe brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     959044156  60549131 0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     744533957  66149681 0       0       0       0
> 
> [root@donkey ~]# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:C0:49:A7:33:FE
>           inet addr:192.168.1.7  Bcast:192.168.1.255  Mask:255.255.255.0
>           inet6 addr: fe80::2c0:49ff:fea7:33fe/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:60551468 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:66152721 errors:0 dropped:0 overruns:1 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:959199592 (914.7 MiB)  TX bytes:748395356 (713.7 MiB)
>           Interrupt:12 Base address:0xce00
> 
> Somehow the "overruns" counter is seen differently by 'ip'
>  and 'ifconfig' - one says 0, the other says 1 - perhaps the
>  packet that WARN'd me on tcp_simple_retransmit ?

...I find that extreme unlikely.

> If there's anything else - reproducing seems really really
>  unlikely - 1 packet in 66 million...

Yeah, it seems some hard to hit corner case and so far nobody has
a reproducable scenario (or at least I'm not aware of any). I tried
to reproduce it last weekend and failed, even with some netem stimuli 
added while torrenting.

I'll probably ask soon Andrew to queue some low cost debug patch into
-mm to get a bit more clues when somebody running mm happens to hit
it.

-- 
 i.
---696208474-1168032753-1207168751=:10610--
