From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Thu, 27 Aug 2015 15:39:12 -0700
Message-ID: <CAM_iQpX4VFeEe4zGj0kx7x7q6GO7Kx+kKC2FW_CRiGSrk0aZVA@mail.gmail.com>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
	<1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
	<20150827.153046.2021133935222197667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35297 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757222AbbH0WjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 18:39:13 -0400
Received: by obbwr7 with SMTP id wr7so28770239obb.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 15:39:12 -0700 (PDT)
In-Reply-To: <20150827.153046.2021133935222197667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 3:30 PM, David Miller <davem@davemloft.net> wrote:
> I don't like this.
>
> The situation is that some sophisticated qdiscs can function without
> explicit parameters, some cannot.

This is exactly what this patch tries to solve... I already mark those
with a DEFAULTABLE flag.

>
> That is the problem you need to solve.  For example, if "opts" is NULL
> HTB should use a reasonable set of defaults instead of failing.
>
> Furthermore, you can improve the behavior when this happens.
>
> When qdisc_create_dflt() returns NULL because ops->init() fails, do
> something reasonable.
>
> I'm not applying this patch series, it papers over the issue rather
> than actually addressing it properly.

I wish I never mention that crash, which leads you to think I am trying
to fix a crash rather than a more important issue, usability. See below.

Forget about the crash, consider the current behavior:

# echo htb > default_qdisc
# succeed without any error
(then add a root qdisc and remove it)
# failure shown here in dmesg


And compare it with the behavior after my patch:

# echo htb > default_qdisc
Invalid arguments

I think this is clearly an improvement.

Thanks.
