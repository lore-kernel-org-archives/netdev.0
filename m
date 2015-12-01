From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 01 Dec 2015 06:06:47 -0800
Message-ID: <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201010005.GA23175@Fux-PC>
	 <CAHA+R7NdbMgfWpdCoP8peXT3zBX1=B_HWhsykjcT3QO=Gk-9aQ@mail.gmail.com>
	 <20151201111943.GA4036@Fux-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	pageexec@freemail.hu, re.emese@gmail.com
To: Daniele Fucini <dfucini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35535 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004AbbLAOGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:06:50 -0500
Received: by pacej9 with SMTP id ej9so6366341pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 06:06:50 -0800 (PST)
In-Reply-To: <20151201111943.GA4036@Fux-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 12:19 +0100, Daniele Fucini wrote:
> Thanks for the reply. Here's the output of `tc qdisc show`:
> https://gist.github.com/1847102c8fe08f63e9e7
> 
> Daniele
> 
> 
> On Mon, Nov 30, 2015 at 08:50:29PM -0800, Cong Wang wrote:
> > On Mon, Nov 30, 2015 at 5:00 PM, Daniele Fucini <dfucini@gmail.com> wrote:
> > > Hello,
> > >
> > > I'm using a Grsecurity patched kernel (version 4.2.6-201511282239) and
> > > I'm getting system freezes due to PaX detecting a size overflow in
> > > function qdisc_tree_decrease_qlen net/sched/sch_api.c:769 whenever I use
> > > Transmission BitTorrent client.
> > >
> > > On the Grsecurity forum I was told it's probably an unintended integer
> > > underflow that I should report upstream.
> > >
> > > Here's the relevant log:
> > > https://gist.github.com/cf54ccbb12ea65e146d4
> > >
> > 
> > Looks like we miss some sch->q.qlen accounting somewhere...
> > 
> > What is your qdisc setup? Is your fq_codel the default one or you installed it
> > or some other qdisc somewhere (`tc qdisc show` could tell)?
> > 
> > I will take a deeper look tomorrow, or maybe Jamal could find something
> > before I wake up. ;)

Hmm... I do not think we ever took care of MQ in
qdisc_tree_decrease_qlen()
