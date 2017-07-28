From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Fri, 28 Jul 2017 09:13:22 -0600
Message-ID: <5a568b1f-a311-f97b-f5d0-5361b33cf6bc@gmail.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
 <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
 <7c17a575-53bb-1f25-4a9a-7418f99660f2@mojatatu.com>
 <886e9fe5-d523-4841-1a81-e5671447933a@gmail.com>
 <b82ef71c-3231-fa71-44f5-8882750822d9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36090 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbdG1PNU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:13:20 -0400
Received: by mail-pf0-f195.google.com with SMTP id m21so6605533pfj.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:13:20 -0700 (PDT)
In-Reply-To: <b82ef71c-3231-fa71-44f5-8882750822d9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/17 9:04 AM, Jamal Hadi Salim wrote:
> 
> Kernel side checking for device ifindex must know what a device
> ifindex means.
> That doesnt disqualify that the generic code checks that it
> is of the same size as a signed 32b, etc. That is generic
> stuff that can be factored out.
> 
> In this case:
> Checking for whether bits selected are in the allowed range
> that the kernel understands, that the bit value are set in
> the right bit position, that the bits set in the correct bit
> value position are also selected in the transaction.
> That is generic code (which the content validation does).

Create a helper function then. It's the validation of attribute content
in 2 places that I object to. 1 attribute is validated in 1 place
(generic infra for this bitfield attribute), the others are validated in
line. Asymmetric validations is not a good design.
