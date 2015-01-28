From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 28 Jan 2015 21:03:14 +0900
Message-ID: <CAAedzxo2JC6yk5Oz2_ya_FrPuDzb+RdS4wi_ri-F2oUK9H9DWw@mail.gmail.com>
References: <1421823759-15098-1-git-send-email-ek@google.com> <1422189993.2148036.218504993.339586EE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:47041 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933059AbbA1Ukf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:40:35 -0500
Received: by mail-vc0-f171.google.com with SMTP id hq11so7541190vcb.2
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 12:40:34 -0800 (PST)
In-Reply-To: <1422189993.2148036.218504993.339586EE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 25, 2015 at 9:46 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi,
>
> On Wed, Jan 21, 2015, at 08:02, Erik Kline wrote:
>>               if (ipv6_addr_equal(&ifp->addr, addr) &&
>> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
>> +                   (!(ifp->flags&IFA_F_TENTATIVE) ||
>> +                    ifp->flags&IFA_F_OPTIMISTIC) &&
>> +                   !(ifp->flags&banned_flags) &&
>>                   (dev == NULL || ifp->idev->dev == dev ||
>
> Can the wrapper take the IFA_F_TENTATIVE and IFA_F_OPTIMISTIC into the
> banned_flags argument, so this condition becomes easier to read? The new
> caller could also specify them verbatim. I think it would improve
> readability.

So I did a bit of fiddling (and some fiddling of bits) and I've got a
working version with your suggestion.

Note that because we use 2 flags to represent optimistic state we
still have a bit of complication in order to check whether or not
optimistic is explicitly banned or not (as opposed to accidentally
banned by virtue of its pairing with tentative).

Thanks,
-Erik
