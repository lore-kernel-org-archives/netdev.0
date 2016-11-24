From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE registers
Date: Thu, 24 Nov 2016 10:25:23 +0100
Message-ID: <CAGm1_ktuAbt0pr_NJu2GLDOavFV_bvMBmH5RvDxr5AyXvfwB3A@mail.gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
 <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com> <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
 <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:33198 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934194AbcKXJZp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 04:25:45 -0500
In-Reply-To: <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 9:15 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/23/2016 12:08 PM, Yegor Yefremov wrote:
>> On Wed, Nov 23, 2016 at 6:33 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> On 11/23/2016 06:38 AM, yegorslists@googlemail.com wrote:
>>>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>>>
>>>> Add the ability to query and set Energy Efficient Ethernet parameters
>>>> via ethtool for applicable devices.
>>>
>>> Are you sure this is enough to actually enable EEE? I don't see where
>>> phy_init_eee() is called here, nor is the cpsw Ethernet controller part
>>> configured to enable/disable EEE. EEE is not just a PHY thing, it
>>> usually also needs to be configured properly at the Ethernet MAC/switch
>>> level as well.
>>>
>>> Just curious here.
>>
>> I'm sure I want to disable EEE :-) So I need this patch in order to
>> check and disable EEE advertising.
>
> OK, so you need this to disable EEE advertisement, which is great, but
> this also allows you to enable EEE, is it enough to just advertise EEE
> with your link partner for cpsw to work correctly? Just wondering, since
> your commit message is more than short.

I've sent v3 with a little bit more info. Basically this is needed for
this kind of issues [1]

As for enabling advertising and correct working of cpsw do you mean it
would be better to disable EEE in any PHY on cpsw initialization as
long as cpsw doesn't provide support for EEE?

We observe some strange behavior with our gigabit PHYs and a link
partner in a EEE-capable unmanaged NetGear switch. Disabling
advertising seems to help. Though we're still investigating the issue.

[1] http://www.spinics.net/lists/netdev/msg405396.html

Yegor
