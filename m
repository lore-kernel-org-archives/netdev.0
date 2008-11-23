From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Sun, 23 Nov 2008 23:40:32 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811232336450.27995@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
 <4928CECE.602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="=_courier-14629-1227411160-0001-2"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39472 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbYKWVkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 16:40:35 -0500
In-Reply-To: <4928CECE.602@cosmosbay.com>
Content-ID: <Pine.LNX.4.64.0811232336451.27995@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_courier-14629-1227411160-0001-2
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811232336452.27995@wrl-59.cs.helsinki.fi>

On Sun, 23 Nov 2008, Eric Dumazet wrote:

> Ilpo Järvinen a écrit :
> > I got plenty of these from sock_prot_inuse_add:
> > 
> > BUG: using smp_processor_id() in preemptible [00000000] code: rcS/1146
> > 
> > caller is sock_prot_inuse_add+0x24/0x42
> > Pid: 1146, comm: rcS Not tainted 2.6.28-rc6-01121-g89a2f15 #76
> > Call Trace:
> >  [<ffffffff80365767>] debug_smp_processor_id+0xd3/0xe8
> >  [<ffffffff80485a0f>] sock_prot_inuse_add+0x24/0x42
> >  [<ffffffff80514cdd>] unix_create1+0x161/0x176
> >  [<ffffffff80514d52>] unix_create+0x60/0x6b
> >  [<ffffffff80483f66>] __sock_create+0x144/0x1bd
> >  [<ffffffff80483edb>] ? __sock_create+0xb9/0x1bd
> >  [<ffffffff8048402d>] sock_create+0x2d/0x2f
> >  [<ffffffff80484274>] sys_socket+0x29/0x5b
> >  [<ffffffff8020c10a>] system_call_fastpath+0x16/0x1b
> > 
> > 
> 
> Thanks Ilpo for this report
> 
> I guess the following is necessary.
> 
> Once Christopher and Rusty work on percpu variables is finished,
> the preempt_enable()/disable() wont be necessary anymore, so
> its a temporary workaround anyway.
> 
> [PATCH] net: make sock_prot_inuse_add() preempt safe
> 
> Ilpo Järvinen reported that commit a8076d8db98de6da61394b2e942320e4612643ac
> (net: af_unix should update its inuse counter) was triggering
> a warning in smp_processor_id(), being called in a preemptible code.
> 
> Fix is to make sock_prot_inuse_add() safe in this regard. This fix
> can be reverted when new percpu infrastructure is ready, allowing
> a cpu to safely do a increment/decrement on a percpu var.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Works.

Tested-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
--=_courier-14629-1227411160-0001-2--
