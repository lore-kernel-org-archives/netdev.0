From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/4] vxlan: support setting IPv6 flow label
Date: Wed, 09 Mar 2016 11:53:29 +0100
Message-ID: <56E000A9.9060001@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>	<7775042611e823098fd14d2929fb6b12cc0b3f98.1457488298.git.daniel@iogearbox.net> <CALx6S37cKnQwMhjjJBodgNbLb7OQ7qzp76Ubr7BVd11SPznGuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49151 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbcCIKxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 05:53:34 -0500
In-Reply-To: <CALx6S37cKnQwMhjjJBodgNbLb7OQ7qzp76Ubr7BVd11SPznGuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2016 04:29 AM, Tom Herbert wrote:
[...]
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index d452cea..6bebc97 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -456,6 +456,7 @@ enum {
>>          IFLA_VXLAN_GBP,
>>          IFLA_VXLAN_REMCSUM_NOPARTIAL,
>>          IFLA_VXLAN_COLLECT_METADATA,
>> +       IFLA_VXLAN_LABEL,
>
> Should this interface align with ip_gre that uses IFLA_GRE_FLOWINFO to
> set both traffic class and flow label in one shot?

For vxlan and geneve by the way, there's already IFLA_VXLAN_TOS and
IFLA_GENEVE_TOS attribute that configure the tos for IPv4 or traffic
class for IPv6 case on the device, and have special handling in the
xmit path that they can inherit the tos/tc when configured as such on
the device in non collect metadata case. Seems like grev6 is handled
differently and also still without tunnel key support, if I see this
correctly. Agree with you that some more consolidation would be nice.

>>          __IFLA_VXLAN_MAX
>>   };
>>   #define IFLA_VXLAN_MAX (__IFLA_VXLAN_MAX - 1)
>> --
>> 1.9.3
