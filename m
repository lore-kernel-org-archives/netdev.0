From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: add a new NETDEV_CHANGEROOM event type
Date: Tue, 20 Aug 2013 16:30:48 +0100
Message-ID: <CAGVrzcahRhYJM-1KcNDOoekKCetSZCN67hHQ0fgjndehZ=9EUw@mail.gmail.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
 <1377002752-4622-2-git-send-email-f.fainelli@gmail.com> <1377011818.13829.9.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, amwang <amwang@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>,
	kaber <kaber@trash.net>, David Miller <davem@davemloft.net>,
	vyasevic <vyasevic@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33484 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab3HTPb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 11:31:29 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so837635pab.25
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 08:31:29 -0700 (PDT)
In-Reply-To: <1377011818.13829.9.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/20 Johannes Berg <johannes@sipsolutions.net>:
> On Tue, 2013-08-20 at 13:45 +0100, Florian Fainelli wrote:
>
>>  /**
>> + *   dev_set_headroom - Change device needed headroom
>> + *   @dev: device
>> + *   @new_headroom: new headroom size
>> + *
>> + *   Change the network device headroom space.
>> + */
>> +int dev_set_headroom(struct net_device *dev, unsigned short new_headroom)
>
> It seems that you need to invoke these under RTNL, might be worth
> documenting that.

Good point, yes.

>
> Also, maybe it would be worth doing it in one call? If you need to
> change both, then you'd end up calling the notifier twice, which is less
> efficient?

I have mixed feelings about this. I do not expect changing the
headroom/tailroom to be in a hot-path, and we would need to have a
name such as dev_set_head_and_tailroom() or something that clearly
states that it operates on both quantities. Looking at the subsystems
and drivers, there are quite a lot of users which only set one or the
other, occasionaly both before registration.

> I suppose you could make them 'int' arguments and reserve -1
> for no changes, or just require both new values to be given (if doing
> this at all.)

What I like about keeping them separate is that we can use the
"native" storage type that is used in struct net_device, and have
compile-time checking of this.
-- 
Florian
