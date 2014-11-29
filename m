From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Sat, 29 Nov 2014 09:51:42 -0800
Message-ID: <547A07AE.7060305@gmail.com>
References: <cover.1417005245.git.tgraf@suug.ch> <547606B3.3060808@gmail.com> <20141126170610.GA2399@casper.infradead.org> <54760D1D.3070201@gmail.com> <20141126231436.GF32174@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:48412 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbaK2Rv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 12:51:56 -0500
Received: by mail-oi0-f46.google.com with SMTP id h136so5756547oig.5
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 09:51:56 -0800 (PST)
In-Reply-To: <20141126231436.GF32174@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 03:14 PM, Thomas Graf wrote:
> On 11/26/14 at 09:25am, John Fastabend wrote:
>>> --- a/net/ipv4/devinet.c
>>> +++ b/net/ipv4/devinet.c
>>> @@ -1687,8 +1687,11 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
>>>                 BUG();
>>>
>>>         if (tb[IFLA_INET_CONF]) {
>>> -               nla_for_each_nested(a, tb[IFLA_INET_CONF], rem)
>>> +               nla_for_each_nested(a, tb[IFLA_INET_CONF], rem) {
>>> +                       if (nla_len(a) < sizeof(u32))
>>> +                               return -EINVAL;
>>>                         ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
>>> +               }
>
> Looked into this and found a validation function
> inet_validate_link_af(). It's split to keep the updates atomic.
>

Ah great thanks.

-- 
John Fastabend         Intel Corporation
