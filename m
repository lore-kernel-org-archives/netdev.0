From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode [gs]etting
Date: Mon, 05 Oct 2015 08:52:48 -0700
Message-ID: <56129CD0.50301@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <1443993949-3915-10-git-send-email-jiri@resnulli.us> <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33098 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbJEPxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:53:03 -0400
Received: by pacex6 with SMTP id ex6so180712826pac.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:53:03 -0700 (PDT)
In-Reply-To: <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-05 08:41 AM, Scott Feldman wrote:
> On Sun, Oct 4, 2015 at 2:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Introduce a stub for allowing user to change rocker port world/mode.
>> This is implemented using rtnl changelink op.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> 
> [cut]
> 
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index 3a5f263..7da768e 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -416,6 +416,17 @@ enum {
>>  };
>>  #define IFLA_GENEVE_MAX        (__IFLA_GENEVE_MAX - 1)
>>
>> +/* Rocker section */
>> +enum {
>> +       IFLA_ROCKER_UNSPEC,
>> +       IFLA_ROCKER_MODE,
>> +       __IFLA_ROCKER_MAX,
>> +};
>> +
>> +#define IFLA_ROCKER_MAX        (__IFLA_ROCKER_MAX - 1)
>> +
>> +#define ROCKER_MODE_MAX 16
> 
> Does this mean there is going to be a "ip link set dev DEV type rocker
> mode MODE" command option?
> 
> It doesn't seem right to be adding driver-specific IFLA_'s here.  I
> think this sets bad precedence for other drivers to add their own
> knobs without thinking about a generic shared mechanism.
> 
> Actually, I don't see the point of letting the user dynamically change
> the port mode.  I would prefer this knob be moved to qemu/rocker.  Let
> the port mode be specified on device creation.
> 

I agree until we have the infrastructure to "understand" what these
knobs are fundamentally doing I would prefer it to stay in qemu/rocker.

I would rather see commands like "add a table", "remove a table", "add
header x to parser" where the operations are well defined. This lends
itself well to flexible devices that can be configured at runtime. At
least this fits more into my mental model of how we have been managing
these devices today. This would allow users to push the "worlds" into
the device to match their use cases e.g. add more l3 ipv4 rules vs l3
ipv6 rules etc.

> -scott
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
