From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: allow to delete a whole device group
Date: Tue, 24 Mar 2015 10:21:51 -0700
Message-ID: <CAM_iQpWcuX_aVzAgOEuUEiQY5MvUJhATUARm1KdqgaXbM7Sbxg@mail.gmail.com>
References: <1427155455-8257-1-git-send-email-xiyou.wangcong@gmail.com>
	<20150324.131105.1048577882668644719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36300 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbbCXRVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:21:52 -0400
Received: by pdbcz9 with SMTP id cz9so227355281pdb.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 10:21:51 -0700 (PDT)
In-Reply-To: <20150324.131105.1048577882668644719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 10:11 AM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon, 23 Mar 2015 17:04:15 -0700
>
>> +     for_each_netdev_safe(net, dev, aux) {
>> +             if (dev->group == group) {
>> +                     const struct rtnl_link_ops *ops;
>> +
>> +                     found = true;
>> +                     ops = dev->rtnl_link_ops;
>> +                     if (!ops || !ops->dellink)
>> +                             return -EOPNOTSUPP;
>> +                     ops->dellink(dev, &list_kill);
>> +             }
>
> These semantics are terrible.
>
> A netlink request should always strive (no, I'll say it _must_) either
> fully perform the requested operation for all relevant objects, or
> have no side effects and return an error.
>
> If need be you must completely unwind all partial changes before
> returning that error, or alternatively defer commiting the
> changes until you can guarantee that all of them can be performed.

Good point.

I don't see a way to unwind the dellink, I think we can scan the list
twice, once for (!ops || !ops->dellink) check, once for dellink().

Thanks.
