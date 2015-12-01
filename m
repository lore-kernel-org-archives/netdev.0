From: Cong Wang <cwang@twopensource.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen net/sched/sch_api.c
Date: Mon, 30 Nov 2015 20:50:29 -0800
Message-ID: <CAHA+R7NdbMgfWpdCoP8peXT3zBX1=B_HWhsykjcT3QO=Gk-9aQ@mail.gmail.com>
References: <20151201010005.GA23175@Fux-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	pageexec@freemail.hu, re.emese@gmail.com
To: Daniele Fucini <dfucini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:34908 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbbLAEua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 23:50:30 -0500
Received: by ykba77 with SMTP id a77so211299703ykb.2
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 20:50:30 -0800 (PST)
In-Reply-To: <20151201010005.GA23175@Fux-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 5:00 PM, Daniele Fucini <dfucini@gmail.com> wrote:
> Hello,
>
> I'm using a Grsecurity patched kernel (version 4.2.6-201511282239) and
> I'm getting system freezes due to PaX detecting a size overflow in
> function qdisc_tree_decrease_qlen net/sched/sch_api.c:769 whenever I use
> Transmission BitTorrent client.
>
> On the Grsecurity forum I was told it's probably an unintended integer
> underflow that I should report upstream.
>
> Here's the relevant log:
> https://gist.github.com/cf54ccbb12ea65e146d4
>

Looks like we miss some sch->q.qlen accounting somewhere...

What is your qdisc setup? Is your fq_codel the default one or you installed it
or some other qdisc somewhere (`tc qdisc show` could tell)?

I will take a deeper look tomorrow, or maybe Jamal could find something
before I wake up. ;)
