From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Sun, 22 Dec 2013 15:31:54 -0500
Message-ID: <52B74C3A.1050900@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>	<52B1B1B1.2060501@mojatatu.com>	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>	<52B1FC6D.7040005@mojatatu.com>	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>	<52B71024.3090504@mojatatu.com> <CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:39234 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296Ab3LVUcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 15:32:00 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so5266650iej.14
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 12:31:57 -0800 (PST)
In-Reply-To: <CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/13 14:42, Cong Wang wrote:
> On Sun, Dec 22, 2013 at 8:15 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> You know qdiscs and filters are removed too when the device
> is gone, right? So isn't that also a policy you are talking about?
>

That is an easy optimization that made sense to make - we
deleted the root of a graph. No need to spam the policy manager.
What we are talking about is deleting a faulty node shared
by multiple graphs and deleting the vertex but then leaving
dangling edges around. Doesnt make sense.
No action that is shared between two flows or devices is EVER
going to be removed because you deleted a qdisc or a netdev.

> This doesn't make any sense to me, if it did, you should remove
> all net device notifications in kernel, right?
>

Refer to above.

> Have you ever thought about how hard it is to remove a mirred action
> upon the device removal? Even with libnl, we still have to:
>
> 1) monitor the device removal notification
> 2) search the action cache to get the action matches the target device
> 3) search for the filters that contains such actions
> 4) remove the action by changing the filters it is attached
>
> Try it and see how much more work you will do, compare it with
> this kernel patch. It would not be hard to conclude which is easier.
>

It is not about ease - it is about correctness.
You are making a macroscopic decision with a microscopic view. This is
why we have control planes. It is like the legs making decisions on
behalf of the brain.


cheers,
jamal
