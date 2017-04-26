From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Patch net 3/3] team: use a larger struct for mac address
Date: Wed, 26 Apr 2017 11:55:42 -0400
Message-ID: <7103fb6b-2483-37c0-48e5-19aa9fd4f386@redhat.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
 <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
 <20170426054033.GA1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: Jiri Pirko <jiri@resnulli.us>, Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935591AbdDZPzp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 11:55:45 -0400
In-Reply-To: <20170426054033.GA1867@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-04-26 1:40 AM, Jiri Pirko wrote:
> Wed, Apr 26, 2017 at 07:03:23AM CEST, xiyou.wangcong@gmail.com wrote:
>> IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
>> but in many places especially bonding, we use struct sockaddr
>> to copy and set mac addr, this could lead to stack out-of-bounds
>> access.
>>
>> Fix it by using a larger address storage.
>>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Cc: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>> drivers/net/team/team.c | 9 ++++++---
>> 1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>> index 85c0124..88878f1 100644
>> --- a/drivers/net/team/team.c
>> +++ b/drivers/net/team/team.c
>> @@ -60,10 +60,13 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
>> static int __set_port_dev_addr(struct net_device *port_dev,
>> 			       const unsigned char *dev_addr)
>> {
>> -	struct sockaddr addr;
>> +	struct {
>> +		unsigned short type;
>> +		unsigned char addr[MAX_ADDR_LEN];
>> +	} addr;
> 
> Wouldn't it make sense to define this struct somewhere in the core
> headers?

We already have struct sockaddr_storage that could be used throughout 
this set as well. We just converted a few pieces of the bonding driver 
over to using it for better support of ipoib bonds, via commit 
faeeb317a5615076dff1ff44b51e862e6064dbd0. Might be better to just use 
that in both bonding and team, rather than having different per-driver 
structs, or Yet Another Address Storage implementation.

-- 
Jarod Wilson
jarod@redhat.com
