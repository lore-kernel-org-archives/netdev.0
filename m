From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next v2] nlmon: use standard rtnetlink link api for
 add/del devices
Date: Tue, 16 Jul 2013 18:10:03 +0200
Message-ID: <51E5705B.9070206@redhat.com>
References: <1372755331-1267-1-git-send-email-jiri@resnulli.us> <loom.20130716T160603-964@post.gmane.org> <51E55D91.5050000@redhat.com> <1561418.Jq9drZzso6@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932183Ab3GPQKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 12:10:15 -0400
In-Reply-To: <1561418.Jq9drZzso6@lx-vladimir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2013 05:59 PM, Vladimir Kondratiev wrote:
> On Tuesday, July 16, 2013 04:49:53 PM Daniel Borkmann wrote:
>> On 07/16/2013 04:08 PM, Vladimir Kondratiev wrote:
>>> Jiri Pirko <jiri <at> resnulli.us> writes:
>>>
>>>> It is not nice when netdev is created right after module load and with
>>>> some implicit name. So rather change nlmon to use standard rtnl link API.
>>>
>>> Could you please elaborate a bit - how to capture netlink skb's after your
>>> patch? Before, it was netdev that may be used with tcpdump. Now, there is
>>> no such netdev. How to create it?
>>
>> modprobe nlmon
>> ip link add type nlmon
>> ip link set nlmon0 up
>>
>> tcpdump -i nlmon0 ....
>>
>> ip link set nlmon0 down
>> ip link del dev nlmon0
>> rmmod nlmon
>
> Thanks a lot! I guess it is worth to have this mentioned somewhere.
> It will save lots of questions. For example, in Kconfig:

Ok, I don't have a strong opinion on the below patch, I'm fine either way.

But, given that for such devices it is *common* to use the standard rtnl
link API (Jiri is right that this is a better/cleaner approach), I'm not
sure if this needs to be documented then ...

> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index b45b240..13acea2 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -247,8 +247,18 @@ config NLMON
>            purpose of this is to analyze netlink messages with packet sockets.
>            Thus applications like tcpdump will be able to see local netlink
>            messages if they tap into the netlink device, record pcaps for further
> -         diagnostics, etc. This is mostly intended for developers or support
> -         to debug netlink issues. If unsure, say N.
> +         diagnostics, etc. Typical flow is:
> +
> +           modprobe nlmon
> +           ip link add type nlmon
> +           ip link set nlmon0 up
> +           tcpdump -i nlmon0 ....
> +           ip link set nlmon0 down
> +           ip link del dev nlmon0
> +           rmmod nlmon
> +
> +         This is mostly intended for developers or support to debug netlink
> +         issues. If unsure, say N.
>
>   endif # NET_CORE
>
