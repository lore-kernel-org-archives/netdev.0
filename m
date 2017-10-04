From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 5/7] net: bonding: Add extack messages for some
 enslave failures
Date: Wed, 4 Oct 2017 11:06:16 -0700
Message-ID: <1d18c43d-0604-3d38-2b68-ca3c7d1ab754@gmail.com>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
 <1507093134-20406-6-git-send-email-dsahern@gmail.com>
 <20171004063828.GB1895@nanopsycho>
 <354fae78-3b04-3807-7392-87c6a3f1b3db@gmail.com>
 <20171004180428.GG1895@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36040 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdJDSGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 14:06:18 -0400
Received: by mail-pg0-f68.google.com with SMTP id i195so5455169pgd.3
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 11:06:18 -0700 (PDT)
In-Reply-To: <20171004180428.GG1895@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/4/17 11:04 AM, Jiri Pirko wrote:
> Wed, Oct 04, 2017 at 05:35:46PM CEST, dsahern@gmail.com wrote:
>> On 10/3/17 11:38 PM, Jiri Pirko wrote:
>>> Wed, Oct 04, 2017 at 06:58:52AM CEST, dsahern@gmail.com wrote:
>>>> A number of bond_enslave errors are logged using the netdev_err API.
>>>> Return those messages to userspace via the extack facility.
>>>>
>>>> Signed-off-by: David Ahern <dsahern@gmail.com>
>>>> ---
>>>> drivers/net/bonding/bond_main.c | 12 ++++++++++++
>>>> 1 file changed, 12 insertions(+)
>>>>
>>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>>> index bc92307c2082..6688dc9154e0 100644
>>>> --- a/drivers/net/bonding/bond_main.c
>>>> +++ b/drivers/net/bonding/bond_main.c
>>>> @@ -1348,12 +1348,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev,
>>>>
>>>> 	/* already in-use? */
>>>> 	if (netdev_is_rx_handler_busy(slave_dev)) {
>>>> +		NL_SET_ERR_MSG(extack,
>>>> +			       "Device is in use and cannot be enslaved");
>>>
>>> Please don't do this kind of wrapping. Just let the string be on the
>>> same line.
>>>
>>
>> Ok, I will do that for bonding only since it is the existing style.
> 
> I don't believe you need to do this wrap for any code. Just don't wrap.
> General code stype says no wrap for strings :)
> 

I do not break / wrap strings; they need to be searchable. I assumed you
meant this is preferred for bonding:

NL_SET_ERR_MSG(extack, "Device is in use and cannot be enslaved");


over what I have done:

NL_SET_ERR_MSG(extack,
	       "Device is in use and cannot be enslaved");
