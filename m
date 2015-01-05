From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 05 Jan 2015 15:29:36 -0800
Message-ID: <54AB1E60.7010800@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32> <20150104111238.GD15305@casper.infradead.org> <54AADEFF.3090306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:61843 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbbAEX3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 18:29:52 -0500
Received: by mail-ob0-f182.google.com with SMTP id wo20so63209244obc.13
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 15:29:52 -0800 (PST)
In-Reply-To: <54AADEFF.3090306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2015 10:59 AM, John Fastabend wrote:

[...]

>>> +#ifndef _UAPI_LINUX_IF_FLOW
>>> +#define _UAPI_LINUX_IF_FLOW
>>> +
>>> +#include <linux/types.h>
>>> +#include <linux/netlink.h>
>>> +#include <linux/if.h>
>>> +
>>> +#define NET_FLOW_NAMSIZ 80
>>
>> Did you consider allocating the memory for names? I don't have a grasp
>> for the typical number of net_flow_* instances in memory yet.
>>
>
> <100k in the devices I have. Maybe Simon can pitch in what is typical
> on the NPUs I'm not sure about them.
>
> Rocker tables can grow as large as needed at the moment.
>
> Allocating the memory may help I'll go ahead and give it a try.
>

One issue with breaking this is up is a couple structures are being
passed as attributes with name[] as a field. I think its best to break
these up passing empty arrays seems to be ugly at best. So I'll need to
adjust some of the messaging as well.

-- 
John Fastabend         Intel Corporation
