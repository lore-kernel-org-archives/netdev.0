From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH V2 net] netdevice: Include NETIF_F_HW_CSUM when
 intersecting features
Date: Fri, 21 Apr 2017 07:33:25 +0200
Message-ID: <20170421053325.GH13789@unicorn.suse.cz>
References: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
 <CAKgT0UcHtWYQDcYda+i8R8WhBKeWbOBZRHDcAmJXZYuP1RM7-Q@mail.gmail.com>
 <b34063e7-e0c2-583d-f809-02386fc175de@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41854 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035323AbdDUFd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:33:27 -0400
Content-Disposition: inline
In-Reply-To: <b34063e7-e0c2-583d-f809-02386fc175de@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 07:19:55PM -0400, Vlad Yasevich wrote:
> 
> Having said that, the other alternative is to inherit hw_features from
> lower devices.  BTW, bonding I think has a similar "issue" you are
> describing since it prefers HW_CSUM if any of the slaves have it set.

It does but bonding uses netdev_increment_features() to combine slave
features and this function handles checksumming like "or", not "and"
(not only checksumming, also flags in NETIF_F_ONE_FOR_ALL).

That said, it's legitimate to ask if we want some of the features to be
handled differently when computing features for a vlan device. My point
before was that if the helper is called netdev_intersect_features(), it
shouldn't return any features that are not supported by both argument
sets, even if all its current users would benefit from slightly
different behaviour. If it does, it's a trap that someone might one day
fall in.

                                                         Michal Kubecek
