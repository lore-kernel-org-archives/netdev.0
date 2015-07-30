From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv3] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Thu, 30 Jul 2015 10:31:34 +0800
Message-ID: <CAPwn2JR=_6NY0T4p6h1VVU77h3y3CiFEdexJ0LJL3sq62V+bew@mail.gmail.com>
References: <1438164858-5253-1-git-send-email-liuhangbin@gmail.com>
	<55B8AD62.1050002@miraclelinux.com>
	<CAPwn2JT6e=f0q=Q5rbqF_6ZejLyj+Ysyk1eP5KTBkGLz-Mpfqg@mail.gmail.com>
	<55B973A6.1060607@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:33151 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbbG3Cbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 22:31:34 -0400
Received: by oixx19 with SMTP id x19so15189210oix.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 19:31:34 -0700 (PDT)
In-Reply-To: <55B973A6.1060607@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-30 8:45 GMT+08:00 YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com>:

>>> How about ignoring hop limit without message is configured value is
>>> larger than 255, BTW?
>>
>> Although set accept_ra_min_hop_limit great than 255 is meaningless,  there
>> is also no need to check it since icmp6_hop_limit will not larger than 255. so
>>
>> +               if (in6_dev->cnf.accept_ra_min_hop_limit <= 255 &&
>> +                   in6_dev->cnf.accept_ra_min_hop_limit <=
>> ra_msg->icmph.icmp6_hop_limit )
>>                         in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
>>
>> is  duplicated check. How do you think?
>
> How about checking in6_dev->cnf.accept_ra_min_hop_limit by outer if, then?
>
>
> if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
>     ra_msg->icmph.icmp6_hop_limit) {
> ...
> }

Then let's move all the if check outside, I will send a v4 patch for you review.

Thanks
Hangbin
