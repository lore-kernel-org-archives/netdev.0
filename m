From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: remove some useless list_del()
Date: Thu, 5 Jun 2014 23:40:47 -0700
Message-ID: <CAM_iQpWeq6a+ighGoLXqDp06t+D97adFrtRpM+ACqtf3J4SUNg@mail.gmail.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
	<1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
	<1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:54184 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbaFFGks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 02:40:48 -0400
Received: by mail-oa0-f42.google.com with SMTP id j17so2291092oag.15
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 23:40:47 -0700 (PDT)
In-Reply-To: <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2014 at 5:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-06-03 at 17:11 -0700, Cong Wang wrote:
>> "list_kill" is allocated on stack and it's a list head,
>> it is pointless to call list_del(&kill_list) especially
>> after unregister_netdevice_many().
>
> How pointless exactly ? Explain more please.
>
> I suggest you read various commits adding these list_del()
>
> f87e6f47933e3ebeced9bb12615e830a72cedce4 is a good start.
>

If after unregister_netdevice_many() dev->unreg_list is still needed,
then it's a nightmare to maintain these list_head's in dev:

struct list_head dev_list;
struct list_head napi_list;
struct list_head unreg_list;
struct list_head close_list;

struct list_head todo_list;

Same for struct net.
