From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH V2 net] netdevice: Include NETIF_F_HW_CSUM when
 intersecting features
Date: Fri, 21 Apr 2017 13:33:58 -0400
Message-ID: <CAGCdqXFM-+OeQFznZ9kcjpnyeBU=1gcdjv1v7RR3KEGPyiZ_GQ@mail.gmail.com>
References: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
 <CAKgT0UcHtWYQDcYda+i8R8WhBKeWbOBZRHDcAmJXZYuP1RM7-Q@mail.gmail.com>
 <b34063e7-e0c2-583d-f809-02386fc175de@redhat.com> <20170421053325.GH13789@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevic@redhat.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33601 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041564AbdDURlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:41:12 -0400
Received: by mail-wr0-f196.google.com with SMTP id w50so8421226wrc.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 10:41:07 -0700 (PDT)
In-Reply-To: <20170421053325.GH13789@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 1:33 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> On Thu, Apr 20, 2017 at 07:19:55PM -0400, Vlad Yasevich wrote:
>>
>> Having said that, the other alternative is to inherit hw_features from
>> lower devices.  BTW, bonding I think has a similar "issue" you are
>> describing since it prefers HW_CSUM if any of the slaves have it set.
>
> It does but bonding uses netdev_increment_features() to combine slave
> features and this function handles checksumming like "or", not "and"
> (not only checksumming, also flags in NETIF_F_ONE_FOR_ALL).
>

I am not saying that it doesn't.  What I am saying is that if you
form a bond with two devices: one with only NETIF_F_IP_CSUM and the
other with NETIF_F_HW_CSUM, then the bonding device will have NETIF_F_HW_CSUM
set.  This is similar to what is being proposed in the patch.

Alex's objection, at least as I understand it, is that we never want to
allow the above condition.  However, it looks like we already allow it
and correctly handle it.

> That said, it's legitimate to ask if we want some of the features to be
> handled differently when computing features for a vlan device. My point
> before was that if the helper is called netdev_intersect_features(), it
> shouldn't return any features that are not supported by both argument
> sets, even if all its current users would benefit from slightly
> different behaviour. If it does, it's a trap that someone might one day
> fall in.

Ok.  I think I understand, but we've always handled the checksum intersection
stangely.  I'll see what I can figure out.

Thanks
-vlad

>
>                                                          Michal Kubecek
>
