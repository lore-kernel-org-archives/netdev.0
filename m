From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when the
 target device is gone
Date: Sun, 22 Dec 2013 11:42:28 -0800
Message-ID: <CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
	<52B1FC6D.7040005@mojatatu.com>
	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
	<52B71024.3090504@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:52759 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569Ab3LVTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 14:42:29 -0500
Received: by mail-oa0-f51.google.com with SMTP id i7so4906916oag.24
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 11:42:28 -0800 (PST)
In-Reply-To: <52B71024.3090504@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 22, 2013 at 8:15 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
>
> I am sorry Cong - I will still object to this change. I dont want
> to even bother testing it.
> You are making some serious policy decisions in the kernel.
> Such policy decisions should be made by user space not the kernel.

You know qdiscs and filters are removed too when the device
is gone, right? So isn't that also a policy you are talking about?

This doesn't make any sense to me, if it did, you should remove
all net device notifications in kernel, right?

> Whoever made the idiotic decision of removing the device should
> modify or delete the flow rule - at minimal they
> may deserve some warning. Deleting the action is wrong. It is simple
> graph theory.

Have you ever thought about how hard it is to remove a mirred action
upon the device removal? Even with libnl, we still have to:

1) monitor the device removal notification
2) search the action cache to get the action matches the target device
3) search for the filters that contains such actions
4) remove the action by changing the filters it is attached

Try it and see how much more work you will do, compare it with
this kernel patch. It would not be hard to conclude which is easier.
