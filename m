From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 8 Aug 2016 10:27:33 -0600
Message-ID: <c5a29670-59df-af6e-17b7-15e44e5589a1@cumulusnetworks.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <39efdc37-88cc-34c4-ad64-2f13fd0bc4a2@cumulusnetworks.com>
 <CAKD1Yr03OGoOGtCB9JTCkpQhiPGh+wZRMB96YNSy4WzR2ckTow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32783 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbcHHQ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 12:27:36 -0400
Received: by mail-pa0-f44.google.com with SMTP id ti13so36991612pac.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 09:27:36 -0700 (PDT)
In-Reply-To: <CAKD1Yr03OGoOGtCB9JTCkpQhiPGh+wZRMB96YNSy4WzR2ckTow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/16 10:24 AM, Lorenzo Colitti wrote:
> On Tue, Aug 9, 2016 at 12:27 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> -     if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
>>> -             fl6.flowi6_oif = np->mcast_oif;
>>> -     else if (!fl6.flowi6_oif)
>>> -             fl6.flowi6_oif = np->ucast_oif;
>>> -
>>
>> That code removal is contrary to your patch description regarding flowi6_oif.
> 
> Which code removal? The one I quote above? That code wasn't removed,
> it was moved to above the initialization of flowi6.
> 

Your description states:
"ping_v6_sendmsg never sets flowi6_oif, so it is not possible to
ping an IPv6 address on a different interface."

That code snippet above contradicts that -- flowi6_oif is set in ping_v6_sendmsg.

You are making a different change than just setting flowi6_oif.
