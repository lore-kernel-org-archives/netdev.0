From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/3] net: add a new NETDEV_CHANGEROOM event type
Date: Tue, 20 Aug 2013 18:10:12 +0200
Message-ID: <20130820161012.GC1593@minipsycho.brq.redhat.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
 <1377002752-4622-2-git-send-email-f.fainelli@gmail.com>
 <1377011818.13829.9.camel@jlt4.sipsolutions.net>
 <CAGVrzcahRhYJM-1KcNDOoekKCetSZCN67hHQ0fgjndehZ=9EUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, amwang <amwang@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	kaber <kaber@trash.net>, David Miller <davem@davemloft.net>,
	vyasevic <vyasevic@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:62773 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab3HTQKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 12:10:16 -0400
Received: by mail-we0-f177.google.com with SMTP id m46so594052wev.22
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 09:10:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAGVrzcahRhYJM-1KcNDOoekKCetSZCN67hHQ0fgjndehZ=9EUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 20, 2013 at 05:30:48PM CEST, f.fainelli@gmail.com wrote:
>2013/8/20 Johannes Berg <johannes@sipsolutions.net>:
>> On Tue, 2013-08-20 at 13:45 +0100, Florian Fainelli wrote:
>>
>>>  /**
>>> + *   dev_set_headroom - Change device needed headroom
>>> + *   @dev: device
>>> + *   @new_headroom: new headroom size
>>> + *
>>> + *   Change the network device headroom space.
>>> + */
>>> +int dev_set_headroom(struct net_device *dev, unsigned short new_headroom)
>>
>> It seems that you need to invoke these under RTNL, might be worth
>> documenting that.
>
>Good point, yes.
>
>>
>> Also, maybe it would be worth doing it in one call? If you need to
>> change both, then you'd end up calling the notifier twice, which is less
>> efficient?
>
>I have mixed feelings about this. I do not expect changing the
>headroom/tailroom to be in a hot-path, and we would need to have a
>name such as dev_set_head_and_tailroom() or something that clearly
>states that it operates on both quantities. Looking at the subsystems
>and drivers, there are quite a lot of users which only set one or the
>other, occasionaly both before registration.
>
>> I suppose you could make them 'int' arguments and reserve -1

Ugh, -1, I don't like this. I think that they should be set separate. Not
real need to do it in one function.

>> for no changes, or just require both new values to be given (if doing
>> this at all.)
>
>What I like about keeping them separate is that we can use the
>"native" storage type that is used in struct net_device, and have
>compile-time checking of this.
>-- 
>Florian
