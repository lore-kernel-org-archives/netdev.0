From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: rtnl_newlink() cleanup on namespace change
Date: Wed, 11 Mar 2015 09:35:00 -0700
Message-ID: <CAM_iQpU95fLZN6+DqAnA7BSf1JRKamaOfehYsORj8m+LTkM2SQ@mail.gmail.com>
References: <20150310.184347.1581730121744725414.davem@davemloft.net>
	<CAM_iQpXNp4+1D454yrwJyER50gKC3N1CtDffEExDYiGCENTiFQ@mail.gmail.com>
	<20150310.220011.1982964437618102167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35987 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbCKQfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:35:01 -0400
Received: by padfa1 with SMTP id fa1so12716313pad.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 09:35:00 -0700 (PDT)
In-Reply-To: <20150310.220011.1982964437618102167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 7:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 10 Mar 2015 16:44:06 -0700
>
>> On Tue, Mar 10, 2015 at 3:43 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> Cong, I was reviewing commit 7afb8886a05be68e376655539a064ec672de8a8e
>>> ("rtnetlink: call ->dellink on failure when ->newlink exists") during
>>> a stable backport and I noticed that the function, after the change
>>> you made, subsequently goes:
>>>
>>>                 if (link_net) {
>>>                         err = dev_change_net_namespace(dev, dest_net, ifname);
>>>                         if (err < 0)
>>>                                 unregister_netdevice(dev);
>>>                 }
>>>
>>> Isn't the potential ->dellink() unwinding necessary in this path too?
>>>
>>
>> Right, I wasn't aware of the link_net change.
>> Do you want me to send a fix?
>
> I took care of it, as follows:

Thanks, it looks good.

>
> ====================
> [PATCH] net: Handle unregister properly when netdev namespace change fails.
>
> If rtnl_newlink() fails on it's call to dev_change_net_namespace(), we
> have to make use of the ->dellink() method, if present, just like we
> do when rtnl_configure_link() fails.
>
> Fixes: 317f4810e45e ("rtnl: allow to create device with IFLA_LINK_NETNSID set")
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
