From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] vxlan: add necessary locking on device removal
Date: Wed, 17 Jul 2013 08:41:33 -0700
Message-ID: <CALnjE+oL8H+owyeUJvqvwEQJ4YjFuszBeBKpnhq9myL9DYptRw@mail.gmail.com>
References: <CALnjE+oDwU46NiK-AyB-dJZVrWT-pot_v+obv+MxgZU0xNwbRw@mail.gmail.com>
	<20130716.112820.260966128083756999.davem@davemloft.net>
	<CALnjE+q65PHMBycfmE2L2DDYuVU_8HrAKJJUtzzjVDVkT+sinA@mail.gmail.com>
	<20130716.230600.734017943782172716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:44520 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756121Ab3GQPln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 11:41:43 -0400
Received: by mail-qe0-f54.google.com with SMTP id ne12so1224364qeb.27
        for <netdev@vger.kernel.org>; Wed, 17 Jul 2013 08:41:33 -0700 (PDT)
In-Reply-To: <20130716.230600.734017943782172716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 11:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Tue, 16 Jul 2013 13:29:08 -0700
>
>> commit 1c51a9159ddefa51 (vxlan: fix race caused by dropping
>> rtnl_unlock) moved sock-create to sock_work workq. Thats why I thought
>> sock_work takes RTNL. but if it is not taking RTNL in any case, they
>> why vxlan sock create is deferred to sock_work?
>
> That commit is handling the fact that the RTNL mutex is NOT held
> during the create operation in question.
>
> It defers to a workqueue so that the new ->sock_lock can be taken
> in the appropriate context.

ok, Thanks for explanation. I do not see any problem with the patch.
