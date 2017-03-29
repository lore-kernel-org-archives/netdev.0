From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link
 messages
Date: Wed, 29 Mar 2017 08:23:58 -0400
Message-ID: <2fe31fc9-2837-91a7-e2a4-7937bb15cf3d@redhat.com>
References: <1490493587-25819-1-git-send-email-vyasevic@redhat.com>
 <20170327.155835.1930829109806331326.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33902 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932074AbdC2MYA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 08:24:00 -0400
In-Reply-To: <20170327.155835.1930829109806331326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ resending to list.  hit the wrong reply button last time ]

On 03/27/2017 06:58 PM, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Sat, 25 Mar 2017 21:59:47 -0400
> 
>> RTNL currently generates notifications on some netdev notifier events.
>> However, user space has no idea what changed.  All it sees is the
>> data and has to infer what has changed.  For some events that is not
>> possible.
>>
>> This patch adds a new field to RTM_NEWLINK message called IFLA_EVENT
>> that would have an encoding of the which event triggered this
>> notification.  Currectly, only 2 events (NETDEV_NOTIFY_PEERS and
>> NETDEV_MTUCHANGED) are supported.  These events could be interesting
>> in the virt space to trigger additional configuration commands to VMs.
>> Other events of interest may be added later.
>>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> 
> At what point do we start providing the metadata for the changed
> values as well?  You'd probably need to provide both the old and
> new values to cover all cases.

I don't think if that would be possible because of when events are triggered.
We send these notifications after all the changes have already been made, so
it might be tough to carry old data.

Looking at just the two events I am supporting in this patch, we could actually
supply the old mtu data through a NETDEV_PRECHANGEMTU event, if it is necessary.
For the use cases I am looking at, it isn't usefull, but easy enough to add.

> 
>> @@ -4044,6 +4076,7 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
>>  	return skb->len;
>>  }
>>  
>> +
>>  /* Process one rtnetlink message. */
>>  
>>  static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> 
> Please don't add more empty lines between functions, one is enough.
> 

Sorry, got left-over after moving the code around.  Will remove when resubmitting.

-vlad
