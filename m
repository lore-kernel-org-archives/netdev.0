From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 2/2] netns: don't allocate an id for dead netns
Date: Sun, 05 Apr 2015 10:39:53 +0200
Message-ID: <5520F4D9.5030103@6wind.com>
References: <551E63B9.9050208@6wind.com>	<1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>	<1428055357-15289-2-git-send-email-nicolas.dichtel@6wind.com> <20150403.123650.1819000124764491725.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33889 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbDEIj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 04:39:56 -0400
Received: by wgbdm7 with SMTP id dm7so6029116wgb.1
        for <netdev@vger.kernel.org>; Sun, 05 Apr 2015 01:39:55 -0700 (PDT)
In-Reply-To: <20150403.123650.1819000124764491725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/04/2015 18:36, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri,  3 Apr 2015 12:02:37 +0200
>
>> First, let's explain the problem.
>> Suppose you have an ipip interface that stands in the netns foo and =
its link
>> part in the netns bar (so the netns bar has an nsid into the netns f=
oo).
>> Now, you remove the netns bar:
>>   - the bar nsid into the netns foo is removed
>>   - the netns exit method of ipip is called, thus our ipip iface is =
removed:
>>     =3D> a netlink message is built in the netns foo to advertise th=
is deletion
>>     =3D> this netlink message requests an nsid for bar, thus a new n=
sid is
>>        allocated for bar and never removed.
>>
>> This patch adds a check in peernet2id() so that an id cannot be allo=
cated for
>> a netns which is currently destroyed.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied.
>
I don't see these patches in your tree, maybe you forget to push them o=
n
kernel.org?
My other series will conflict with these patches, is it possible to mer=
ge
net into net-next after them?
