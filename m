From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 2/2] ipv4 igmp: use del_timer_sync instead of del_timer in ip_mc_down
Date: Thu, 5 Sep 2013 10:22:53 -0700
Message-ID: <CAO7SqHA4LJhy_NBkPLViJB3s7hM85qd88pmjy3hq-hCCuQstaA@mail.gmail.com>
References: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com>
	<20130905084312.091f73b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:51659 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab3IERWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:22:54 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz11so777987veb.31
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 10:22:53 -0700 (PDT)
In-Reply-To: <20130905084312.091f73b7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 8:43 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed,  4 Sep 2013 23:43:24 -0700
> Salam Noureddine <noureddine@aristanetworks.com> wrote:
>
>> Delete timers using del_timer_sync in ip_mc_down. Otherwise, it is
>> possible for the timer to be the last to release its reference to the
>> in_device and since __in_dev_put doesn't destroy the in_device we
>> would end up leaking a reference to the net_device and see messages
>> like the following,
>>
>> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
>>
>> Tested on linux-3.4.43.
>>
>> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
>
> Why not just call in_dev_put instead which just proper cleanup.
> It is less risky of deadlock than del_timer_sync.

I was wondering if there was a reason behind using __in_dev_put since
the multicast code
is the only user of that function. I can test using in_dev_put
instead. Should __in_dev_put
be removed altogether in that case?

Thanks,

Salam
