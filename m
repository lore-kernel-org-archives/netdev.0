From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Tue, 25 Jul 2017 08:41:43 -0600
Message-ID: <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38248 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdGYOlq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:41:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id c23so13079313pfe.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 07:41:46 -0700 (PDT)
In-Reply-To: <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/17 7:35 PM, Jamal Hadi Salim wrote:
> In the most basic form, the user specifies the attribute policy as:
> [ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
> 
> where myvalidflags is the bit mask of the flags the kernel understands.
> 
> If the user _does not_ provide myvalidflags then the attribute will
> also be rejected.

No other netlink attribute has this requirement. Users of the attributes
are the only ones that know if a value is valid or not (e.g, attribute
passing a device index) and those are always checked in line.
Furthermore, you are locking this attribute into a static meaning of
what is a valid value when flags can be valid or invalid based on other
attributes passed in the request.
