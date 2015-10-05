From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode
 [gs]etting
Date: Mon, 5 Oct 2015 18:37:38 +0200
Message-ID: <20151005163738.GP2278@nanopsycho.orion>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
 <1443993949-3915-10-git-send-email-jiri@resnulli.us>
 <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com>
 <56129CD0.50301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35870 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbbJEQhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 12:37:41 -0400
Received: by wicgb1 with SMTP id gb1so127813335wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 09:37:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56129CD0.50301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 05:52:48PM CEST, john.fastabend@gmail.com wrote:
>On 15-10-05 08:41 AM, Scott Feldman wrote:
>> On Sun, Oct 4, 2015 at 2:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> Introduce a stub for allowing user to change rocker port world/mode.
>>> This is implemented using rtnl changelink op.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> 
>> [cut]
>> 
>>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>> index 3a5f263..7da768e 100644
>>> --- a/include/uapi/linux/if_link.h
>>> +++ b/include/uapi/linux/if_link.h
>>> @@ -416,6 +416,17 @@ enum {
>>>  };
>>>  #define IFLA_GENEVE_MAX        (__IFLA_GENEVE_MAX - 1)
>>>
>>> +/* Rocker section */
>>> +enum {
>>> +       IFLA_ROCKER_UNSPEC,
>>> +       IFLA_ROCKER_MODE,
>>> +       __IFLA_ROCKER_MAX,
>>> +};
>>> +
>>> +#define IFLA_ROCKER_MAX        (__IFLA_ROCKER_MAX - 1)
>>> +
>>> +#define ROCKER_MODE_MAX 16
>> 
>> Does this mean there is going to be a "ip link set dev DEV type rocker
>> mode MODE" command option?
>> 
>> It doesn't seem right to be adding driver-specific IFLA_'s here.  I
>> think this sets bad precedence for other drivers to add their own
>> knobs without thinking about a generic shared mechanism.
>> 
>> Actually, I don't see the point of letting the user dynamically change
>> the port mode.  I would prefer this knob be moved to qemu/rocker.  Let
>> the port mode be specified on device creation.
>> 
>
>I agree until we have the infrastructure to "understand" what these
>knobs are fundamentally doing I would prefer it to stay in qemu/rocker.

Why? If it is possible to set it from driver, why not to expose this to
user? I don't see a point.

Let's find an interface and do it. Note that this is far from the first
thing that could be set from userspace and is not possible, just because
there is no suitable interface. Vendors then come up with some arbitrary
blob-based solution to do it. Far from nice :/


>
>I would rather see commands like "add a table", "remove a table", "add
>header x to parser" where the operations are well defined. This lends
>itself well to flexible devices that can be configured at runtime. At
>least this fits more into my mental model of how we have been managing
>these devices today. This would allow users to push the "worlds" into
>the device to match their use cases e.g. add more l3 ipv4 rules vs l3
>ipv6 rules etc.

Again, to make this clear, worlds are not just a rehash of tables.


>
>> -scott
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>
