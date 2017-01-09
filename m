From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Mon, 9 Jan 2017 17:06:32 +0100
Message-ID: <20170109160632.GD1862@nanopsycho>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
 <20170109073236.GA1862@nanopsycho>
 <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109151131.GC1862@nanopsycho>
 <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35086 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965285AbdAIQGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 11:06:35 -0500
Received: by mail-wj0-f193.google.com with SMTP id ey1so5948159wjd.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 08:06:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 09, 2017 at 04:45:33PM CET, vivien.didelot@savoirfairelinux.com wrote:
>Hi Jiri,
>
>Jiri Pirko <jiri@resnulli.us> writes:
>
>>>Extra question: shouldn't phys_port_{id,name} be switchdev attributes in
>>
>> Again, phys_port_id has nothing to do with switches. Should be removed
>> from dsa because its use there is incorrect.
>
>Florian, since 3a543ef just got in, can it be reverted?

Yes, please revert it. It is only in net-next.


>
>>>> I guess that it should be enough for you to implement
>>>> ndo_get_phys_port_name.
>>>
>>>Well, if this name must be unique on a system, it's not likely to happen
>>>until we agree that we use an ugly tXsYpZ template where X is a tree ID,
>>>or we assign system-wide unique IDs to switches, which requires a bit of
>>>changes.
>>
>> No. That should be unique within one switch. In mlxsw we name it "p1",
>> "p2", ...
>>
>> The final netdev names are:
>> enp3s0np1, enp3s0np2, ...
>
>OK perfect then, "p%d" sounds good. You seems to avoid "p0" in mlxsw, is
>there a reason for that?

We name these according to the front panel name. There's no "port 0"
on the front panel :)


>
>>>But again, this is not related to this patch ;-)
>>
>> It is! You are using phys_port_id, which is completely wrong. You should
>> not use it.
>
>I can resend this patch without the udev examples in the commit message
>if that can be less confusing.

Yes please.


>
>Thanks,
>
>        Vivien
