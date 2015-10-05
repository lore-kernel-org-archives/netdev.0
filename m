From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode
 [gs]etting
Date: Mon, 5 Oct 2015 19:12:20 +0200
Message-ID: <20151005171219.GR2278@nanopsycho.orion>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
 <1443993949-3915-10-git-send-email-jiri@resnulli.us>
 <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com>
 <20151005155320.GN2278@nanopsycho.orion>
 <CAE4R7bD=SFKgifw=xPudoFfHMcFAdGbVToQdvA9HrnFs3pjRYg@mail.gmail.com>
 <20151005165004.GQ2278@nanopsycho.orion>
 <CAE4R7bCScLWpT9g3-LX31jd3Rap1+p3YU8WstxKECThcpqh3qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36475 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbbJERMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:12:23 -0400
Received: by wicgb1 with SMTP id gb1so129192706wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:12:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCScLWpT9g3-LX31jd3Rap1+p3YU8WstxKECThcpqh3qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 07:00:06PM CEST, sfeldma@gmail.com wrote:
>On Mon, Oct 5, 2015 at 9:50 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Oct 05, 2015 at 06:37:20PM CEST, sfeldma@gmail.com wrote:
>>>On Mon, Oct 5, 2015 at 8:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Mon, Oct 05, 2015 at 05:41:29PM CEST, sfeldma@gmail.com wrote:
>>>>>On Sun, Oct 4, 2015 at 2:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>>>
>>>>>> Introduce a stub for allowing user to change rocker port world/mode.
>>>>>> This is implemented using rtnl changelink op.
>>>>>>
>>>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>>>
>>>>>[cut]
>>>>>
>>>>>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>>>>> index 3a5f263..7da768e 100644
>>>>>> --- a/include/uapi/linux/if_link.h
>>>>>> +++ b/include/uapi/linux/if_link.h
>>>>>> @@ -416,6 +416,17 @@ enum {
>>>>>>  };
>>>>>>  #define IFLA_GENEVE_MAX        (__IFLA_GENEVE_MAX - 1)
>>>>>>
>>>>>> +/* Rocker section */
>>>>>> +enum {
>>>>>> +       IFLA_ROCKER_UNSPEC,
>>>>>> +       IFLA_ROCKER_MODE,
>>>>>> +       __IFLA_ROCKER_MAX,
>>>>>> +};
>>>>>> +
>>>>>> +#define IFLA_ROCKER_MAX        (__IFLA_ROCKER_MAX - 1)
>>>>>> +
>>>>>> +#define ROCKER_MODE_MAX 16
>>>>>
>>>>>Does this mean there is going to be a "ip link set dev DEV type rocker
>>>>>mode MODE" command option?
>>>>>
>>>>>It doesn't seem right to be adding driver-specific IFLA_'s here.  I
>>>>>think this sets bad precedence for other drivers to add their own
>>>>>knobs without thinking about a generic shared mechanism.
>>>>
>>>> I understand you point. I somehow share it as well. But on the other
>>>> hand, That is neat way to set mode of the port, and I cannot find other
>>>> this nice.
>>>>
>>>>
>>>>>
>>>>>Actually, I don't see the point of letting the user dynamically change
>>>>>the port mode.  I would prefer this knob be moved to qemu/rocker.  Let
>>>>>the port mode be specified on device creation.
>>>>
>>>> Hmm, interesting, why? I find it great for user to be able to switch the
>>>> port mode easily on the running system. It is a setting of a port.
>>>> I don't see why this should be a hard-coded hw setting. We just have
>>>> to find a way to expose this to user.
>>>
>>>You could just as easy restart the qemu session with different port
>>>mode.  Even if rocker was a real device, I don't see (real) users
>>>wanting to change the port mode at run-time.  It just doesn't seem
>>>like a real-world scenario.   I know it's convenient for developers,
>>
>> We the hw-iface is already designed for on-fly changes.
>> I'm convinced that this is one of the situation where we should not do
>> stuff in HW just because we can. (Or we should do both).
>
>I've used that argument myself for other things, such as the ageing
>timer in rocker driver, so I agree with you on that point.
>
>> We should develop in-kernel solution in order to wrap up HW functionality.
>> Even if not easy. That is the purpose of rocker from day 1, and that is
>> why we love it :)
>
>Well then you need to define a generic interface for this concept of
>changing port mode that's not rocker-specific.  What you have in
>if_link.h is easy.  What's the not-easy solution?

I went the easy way as it kind-of looked correct to me. But I guess we
need to find a different interface. Thing is, settings like this will
always be HW-specific, because they are HW-specific :)

I will leave the userspace expose out of the patchset and re-post. I'll
handle that later-on.
