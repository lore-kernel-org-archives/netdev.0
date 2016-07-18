From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched/sch_htb: clamp xstats tokens to fit into 32-bit int
Date: Mon, 18 Jul 2016 11:29:33 -0700
Message-ID: <CAM_iQpUHeNKGbjRY13nTp4F5fgEitQXz2W2C9GbqS+ygNhZGHg@mail.gmail.com>
References: <146867813621.23552.6234170020058724059.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34525 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbcGRS3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 14:29:53 -0400
In-Reply-To: <146867813621.23552.6234170020058724059.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 16, 2016 at 7:08 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> In kernel HTB keeps tokens in signed 64-bit in nanoseconds. In netlink
> protocol these values are converted into pshed ticks (64ns for now) and
> truncated to 32-bit. In struct tc_htb_xstats fields "tokens" and "ctokens"
> are declared as unsigned 32-bit but they could be negative thus tool 'tc'
> prints them as signed. Big values loose higher bits and/or become negative.
>
> This patch clamps tokens in xstat into range from INT_MIN to INT_MAX.
> In this way it's easier to understand what's going on here.

Makes sense to me, I don't know why we didn't use signed int in
the beginning, interpreting an unsigned int as signed is confusing.
