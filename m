From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 1/2] ipv6 mcast: use del_timer_sync instead of del_timer
 in ipv6_mc_down
Date: Tue, 10 Sep 2013 11:20:18 -0700
Message-ID: <CAO7SqHCsRrZYEQqFCCdroyGZUoa8RX_U0CXMTaG7efRKuCRjvw@mail.gmail.com>
References: <1378363359-37716-1-git-send-email-noureddine@aristanetworks.com>
	<1378391415.3159.3.camel@bwh-desktop.uk.level5networks.com>
	<CAO7SqHA7R8-r_G+-oZfg-zUTnkG2wNCWwY6bRar77dnZPS13ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:36764 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3IJSUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 14:20:19 -0400
Received: by mail-vc0-f177.google.com with SMTP id gf12so5160488vcb.22
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 11:20:19 -0700 (PDT)
In-Reply-To: <CAO7SqHA7R8-r_G+-oZfg-zUTnkG2wNCWwY6bRar77dnZPS13ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran our usual workload with lockdep enabled and didn't see any
lockdep complaints.
Another approach to solve this would be to use in6_dev_put instead of
__in6_dev_put
int the multicast code. I am not sure though why __in6_dev_put was
originally used.
This part of the code seems to not have been changed since the initial
git check-in.

Thanks,

Salam

On Thu, Sep 5, 2013 at 10:20 AM, Salam Noureddine
<noureddine@aristanetworks.com> wrote:
> On Thu, Sep 5, 2013 at 7:30 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>>> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
>>> index 99cd65c..5c8d49d 100644
>>> --- a/net/ipv6/mcast.c
>>> +++ b/net/ipv6/mcast.c
>>> @@ -2277,12 +2277,12 @@ void ipv6_mc_down(struct inet6_dev *idev)
>>>
>>>       read_lock_bh(&idev->lock);
>>>       idev->mc_ifc_count = 0;
>>> -     if (del_timer(&idev->mc_ifc_timer))
>>> +     if (del_timer_sync(&idev->mc_ifc_timer))
>>
>> Are you sure this doesn't introduce a potential deadlock?  Have you
>> tested this with lockdep enabled?
>>
>> Ben.
>
> I will test with lockdep enabled and get back to you.
>
> Thanks,
>
> Salam
