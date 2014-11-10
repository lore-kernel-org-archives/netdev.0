From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v2 03/10] rtnl: expose physical switch id for
 particular device
Date: Mon, 10 Nov 2014 14:31:25 -0800
Message-ID: <54613CBD.7090501@gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-4-git-send-email-jiri@resnulli.us> <5460FCB0.1040409@cumulusnetworks.com> <20141110221419.GA2061@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:38630 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaKJWcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 17:32:03 -0500
Received: by mail-ob0-f181.google.com with SMTP id uy5so6493081obc.40
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 14:32:02 -0800 (PST)
In-Reply-To: <20141110221419.GA2061@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2014 02:14 PM, Jiri Pirko wrote:
> Mon, Nov 10, 2014 at 06:58:08PM CET, roopa@cumulusnetworks.com wrote:
>> On 11/9/14, 2:51 AM, Jiri Pirko wrote:
>>> The netdevice represents a port in a switch, it will expose
>>> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
>>> belong to one physical switch.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>   include/uapi/linux/if_link.h |  1 +
>>>   net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>>>   2 files changed, 26 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>> index 7072d83..4163753 100644
>>> --- a/include/uapi/linux/if_link.h
>>> +++ b/include/uapi/linux/if_link.h
>>> @@ -145,6 +145,7 @@ enum {
>>>   	IFLA_CARRIER,
>>>   	IFLA_PHYS_PORT_ID,
>>>   	IFLA_CARRIER_CHANGES,
>>> +	IFLA_PHYS_SWITCH_ID,
>>
>> Jiri, since we have not really converged on the switchdev class or having a
>> separate switchdev instance,
>> am thinking it is better if we dont expose any such switch_id to userspace
>> yet until absolutely needed. Do you need it today ?
>> There is no real in kernel hw switch driver that will use it today. And quite
>> likely this will need to change when we introduce real hw switch drivers.
>
> When and if the switchdev class is introduced, switch id can happily
> live on. It is nothing against it. Userspace should use this id to group
> the ports of physical switch.
>
>

+1 I think we need this otherwise how will userspace "know" how the
ports are related? If I have two switch silicon blocks in a single
platform or perhaps have a switch silicon with traditional host
nics on the same platform.


-- 
John Fastabend         Intel Corporation
