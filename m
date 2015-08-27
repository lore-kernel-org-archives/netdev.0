From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Thu, 27 Aug 2015 15:47:55 -0700
Message-ID: <CAM_iQpWscW+F4pnDXwn6uVsyaxVrYmUL6c8YF4wam29Lb4SVvg@mail.gmail.com>
References: <1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
	<20150827.153046.2021133935222197667.davem@davemloft.net>
	<CAM_iQpX4VFeEe4zGj0kx7x7q6GO7Kx+kKC2FW_CRiGSrk0aZVA@mail.gmail.com>
	<20150827.154202.1831965840563413727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33019 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096AbbH0Wr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 18:47:56 -0400
Received: by oigm66 with SMTP id m66so15236276oig.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 15:47:55 -0700 (PDT)
In-Reply-To: <20150827.154202.1831965840563413727.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 3:42 PM, David Miller <davem@davemloft.net> wrote:
>
> Long term it's the wrong fix, trust me.

So we have plan to convert some non-defaultable qdisc to defaultable?
I don't see a reason here.

>
> If you fix it properly, by making every qdisc capable of being ->init()'d
> without explicit parameters, it will be the best behavior overall.

The problem is ->init() is not even called when setting it as default,
since setting a default qdisc doesn't need to create a qdisc. This is
why the flag has to be in ops->flags rather than qdisc->flags.
