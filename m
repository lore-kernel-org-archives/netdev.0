From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Thu, 18 Sep 2014 10:36:01 -0700
Message-ID: <CA+HUmGh2JnuagLxYv6-FgviHTzi+LJzYnfLuhZh1iRxLVSWWbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:48905 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437AbaIRRgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 13:36:02 -0400
Received: by mail-ig0-f174.google.com with SMTP id r10so1725466igi.1
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 10:36:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>> May be a better solution is:
>>
>>         features = netdev_increment_features(vlan->lowerdev->features & MACVLAN_FEATURS,
>>                                              features,
>>                                              mask);
>>
>> This way we start with only the feature MACVLAN is interested in.
>
> Seems correct, since it will also prevent other non-macvlan features from
> appearing.
>
> Thanks Vlad.

I verified that this approach also solves my original problem (moving
a macvlan on top of a bonding device to a different namespace).
I do not know how to fully test it with different types of lower
devices and features though.
If anybody wants to take the lead on this it would be great. Otherwise
a more limited patch only clearing the  NETIF_F_NETNS_LOCAL bit was
also submitted earlier
(http://marc.info/?l=linux-netdev&m=141097807310566&w=2).

Thanks,
Francesco
