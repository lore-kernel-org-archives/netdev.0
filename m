From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] cls_cgroup: fix memory leak in cls_cgroup_change()
Date: Mon, 6 Jan 2014 15:23:09 -0800
Message-ID: <CAM_iQpU8rvceS7tAgv6DacHvaxJFBFDJSFhhBhWV-wqJ+A_xOA@mail.gmail.com>
References: <1388776399-27657-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140103.210209.901517258686201934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:49976 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933139AbaAFXXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 18:23:09 -0500
Received: by mail-ob0-f182.google.com with SMTP id wp4so19318633obc.27
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 15:23:09 -0800 (PST)
In-Reply-To: <20140103.210209.901517258686201934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 3, 2014 at 6:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Fri,  3 Jan 2014 11:13:19 -0800
>
>> Fix it by moving allocation to ->init().
>>
>> Cc: Thomas Graf <tgraf@suug.ch>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> I don't understand how the memory leak can happen, please explain
> it in your commit message.
>

The leak happens when ->change() fails after the allocation
inside  cls_cgroup_change(), its caller only does cleanup
when itself creates one. So, the callee should do cleanup
on error path by itself. But I may miss something.

Since it is not urgent at all, I will explain this in changelog
and resend it for net-next.

> Also:
>
>>  {
>> +     struct cls_cgroup_head *head;
>> +     head = kzalloc(sizeof(*head), GFP_KERNEL);
>
> Please add an empty line between local variable declarations
> and code.
>

OK.
