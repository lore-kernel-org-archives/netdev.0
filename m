From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 09:20:28 -0800
Message-ID: <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	 <52B434FA.8080309@mojatatu.com>
	 <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B45851.90208@mojatatu.com>
	 <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f52.google.com ([209.85.128.52]:32795 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab3LTRUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 12:20:32 -0500
Received: by mail-qe0-f52.google.com with SMTP id ne12so2644690qeb.11
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:20:31 -0800 (PST)
In-Reply-To: <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 08:07 -0800, Eric Dumazet wrote:
> On Fri, 2013-12-20 at 09:46 -0500, Jamal Hadi Salim wrote:
> 
> > That is strange - I have net-next from when these patches made it
> > in and no problem booting with statically linked mirred.
> > I will try to pull the latest later and rebuild.
> > The patch above will fix the issue on the dumping of actions. I am only
> > these additional patches I havent paid much attention to.
> 
> Please note boot is OK.
> 
> Some application plays netlink games, I have no idea which ones.
> 
> Not sure I'll have the time to take a deeper look in following days.
> 
> 

The winner is :

edumazet@manihi:~/git/net-next$ git bisect log
# bad: [79c11f2e3fd3e0e3594d4155821ef426153a773f] sch_cbq: remove
unnecessary null pointer check
# good: [f52ed89971adbe79b6438c459814034707b8ab91] pkt_sched: fq: fix
pacing for small frames
git bisect start '79c11f2e3fd3' 'f52ed89971ad' '--' 'net/sched'
# good: [4f8f61eb4341be07b4a8d046f646fcf934a89949] net_sched: expand
control flow of macro SKIP_NONLOCAL
git bisect good 4f8f61eb4341be07b4a8d046f646fcf934a89949
# good: [89819dc01f4c5920783f561597a48d9d75220e9e] net_sched: convert
tcf_hashinfo to hlist and use spinlock
git bisect good 89819dc01f4c5920783f561597a48d9d75220e9e
# good: [d55d282e6af88120ad90e93a88f70e3116dc0e3d] sch_tbf: use do_div()
for 64-bit divide
git bisect good d55d282e6af88120ad90e93a88f70e3116dc0e3d
# bad: [143c9054949436cb05e468439dc5e46231f33d09] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 143c9054949436cb05e468439dc5e46231f33d09
# bad: [3627287463b4acddb83d24fabb1e0a304e39565c] net_sched: convert
tcf_proto_ops to use struct list_head
git bisect bad 3627287463b4acddb83d24fabb1e0a304e39565c
# good: [1f747c26c48bb290c79c34e155860c7e2ec3926a] net_sched: convert
tc_action_ops to use struct list_head
git bisect good 1f747c26c48bb290c79c34e155860c7e2ec3926a
# first bad commit: [3627287463b4acddb83d24fabb1e0a304e39565c]
net_sched: convert tcf_proto_ops to use struct list_head
