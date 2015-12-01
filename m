From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 01 Dec 2015 15:10:31 -0800
Message-ID: <1449011431.32764.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201010005.GA23175@Fux-PC>
	 <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DC716.22673.2DBA261B@pageexec.freemail.hu>
	 <1448987660.2977.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NiYjhE5dY7HPkWuoTA5WMqF3zPyCFk5i3LYTUrYD7gYA@mail.gmail.com>
	 <1448996964.16994.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NRsKrdVAY7_Wyvq1COAGjjkGZdJxZLvDRGS7gaN3iQvQ@mail.gmail.com>
	 <1449000371.16994.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449009185.32764.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M++LboS_2OmhNjoApvFf6Xk-e+vsEgZrFeKG+k1J8edw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pageexec@freemail.hu, Daniele Fucini <dfucini@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	re.emese@gmail.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36409 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180AbbLAXKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 18:10:33 -0500
Received: by pacdm15 with SMTP id dm15so19487639pac.3
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 15:10:33 -0800 (PST)
In-Reply-To: <CAHA+R7M++LboS_2OmhNjoApvFf6Xk-e+vsEgZrFeKG+k1J8edw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 14:47 -0800, Cong Wang wrote:
> On Tue, Dec 1, 2015 at 2:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Hmm... it looks like we have a much more serious bug :
> >
> > qdisc_lookup() calls qdisc_match_from_root(dev->qdisc, handle) without
> > proper lock being held, so we might actually crash the host,
> > if qdisc_tree_decrease_qlen() happens at the time qdiscs are changed.
> >
> > qdisc_tree_decrease_qlen() needs serious care :(
> 
> Convert qdisc list to RCU protected?

Yes, or/and add a per txqueue list, to shorten lookup times !

If we have a per txqueue list, we do not need RCU as we already own the
qdisc lock.
