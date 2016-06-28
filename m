From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Tue, 28 Jun 2016 10:28:39 -0700
Message-ID: <CAM_iQpVQZOh7LaCxSH0JXj4iHn0bt0vhZgcpsh8C99gor+ZO0A@mail.gmail.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160414151813.GE3715@orbyte.nwl.cc> <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LNX.2.00.1606281717140.6874@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34602 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbcF1R27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 13:28:59 -0400
In-Reply-To: <alpine.LNX.2.00.1606281717140.6874@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 8:19 AM, Jiri Kosina <jikos@kernel.org> wrote:
> BTW, I've started to actually work on fixing this, and I've noticed that
> TBF behavior actually violates what's stated in pfifo_fast manpage:
>
> ==========
>         Whenever  an  interface is created, the pfifo_fast qdisc is
>         automatically used as a queue. If another qdisc is
>         attached, it preempts the default pfifo_fast, which automatically
>         returns to function when an  existing  qdisc is detached.
>
>         In this sense this qdisc is magic, and unlike other qdiscs.
> ==========

It is out of date, now default qdisc can be set to any other qdisc
via /proc. Also, probably due to historical reasons, we don't have
a unified default default qdisc, some uses bfifo, some uses pfifo,
we may break some existing script if we change that.
