From: Wakko Warner <wakko@animx.eu.org>
Subject: Re: [PATCH net] ipv4: only create late gso-skb if skb is already set
 up with CHECKSUM_PARTIAL
Date: Fri, 26 Feb 2016 06:12:33 -0500
Message-ID: <20160226111233.GA30599@animx.eu.org>
References: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
 <20160226000706.GA25882@animx.eu.org>
 <20160226004549.GA670@animx.eu.org>
 <56CFFD80.802@stressinduktion.org>
Reply-To: Wakko Warner <wakko@animx.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tn-76-7-162-101.sta.embarqhsd.net ([76.7.162.101]:41274 "EHLO
	animx.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065AbcBZLMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 06:12:36 -0500
Content-Disposition: inline
In-Reply-To: <56CFFD80.802@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> On 26.02.2016 01:45, Wakko Warner wrote:
> >Now there's another one:
> >[  777.315931] ------------[ cut here ]------------
> >[  777.316099] WARNING: CPU: 0 PID: 1404 at /usr/src/linux/dist/4.4-nobklcd/net/ipv4/af_inet.c:155 inet_sock_destruct+0x1cb/0x1f0()
> >[  777.316189] Modules linked in: nfsv3 af_packet scsi_transport_iscsi nfsd auth_rpcgss oid_registry exportfs nfs lockd grace sunrpc ipv6 ata_piix libata evdev virtio_balloon virtio_net unix
> >[  777.316416] CPU: 0 PID: 1404 Comm: kworker/0:1H Not tainted 4.4.0 #2
> >[  777.316468] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
> >[  777.316547] Workqueue: rpciod xprt_autoclose [sunrpc]
> >[  777.316598]  ffffffff815053f0 ffffffff811d46ee 0000000000000000 ffffffff81041383
> >[  777.316680]  ffff88003d268b40 ffff88003d268cc0 ffff88003d07b3f8 ffff88003d07b368
> >[  777.316763]  0000000000000000 ffffffff8136f53b ffff88003d268b40 ffff8800160f2d40
> >[  777.316845] Call Trace:
> >[  777.316868]  [<ffffffff811d46ee>] ? dump_stack+0x47/0x69
> >[  777.316911]  [<ffffffff81041383>] ? warn_slowpath_common+0x73/0xa0
> >[  777.316963]  [<ffffffff8136f53b>] ? inet_sock_destruct+0x1cb/0x1f0
> >[  777.317018]  [<ffffffff812fe003>] ? sk_destruct+0x13/0xc0
> >[  777.317061]  [<ffffffff8136e301>] ? inet_release+0x31/0x50
> >[  777.317108]  [<ffffffff812f7ad5>] ? sock_release+0x15/0x70
> >[  777.317153]  [<ffffffffa00c6109>] ? xs_close+0x9/0x20 [sunrpc]
> >[  777.317206]  [<ffffffffa00c40bd>] ? xprt_autoclose+0x2d/0x60 [sunrpc]
> >[  777.317261]  [<ffffffff81054be9>] ? process_one_work+0x129/0x3f0
> >[  777.317313]  [<ffffffff81054ef2>] ? worker_thread+0x42/0x490
> >[  777.317367]  [<ffffffff81054eb0>] ? process_one_work+0x3f0/0x3f0
> >[  777.317421]  [<ffffffff81059ae8>] ? kthread+0xb8/0xd0
> >[  777.317465]  [<ffffffff81059a30>] ? kthread_worker_fn+0x100/0x100
> >[  777.317521]  [<ffffffff813a29bf>] ? ret_from_fork+0x3f/0x70
> >[  777.317564]  [<ffffffff81059a30>] ? kthread_worker_fn+0x100/0x100
> >[  777.317618] ---[ end trace 220e17a0bf3ec971 ]---
> >
> >This one happened on the client side VM.  There was only 1 NFS mount.  The
> >server VM didn't show anything nor did the host.
> 
> Can you send me your specific kernel version? There are multiple
> WARN_ONs and I want to catch the right one.

Same version as before.  4.4.1.

-- 
 Microsoft has beaten Volkswagen's world record.  Volkswagen only created 22
 million bugs.
