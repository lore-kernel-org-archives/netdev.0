From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next v4 2/3] newly configured FDB ageing time becomes
 effective immediately
Date: Wed, 18 Mar 2015 17:06:05 +0530
Message-ID: <CA+CtxLQEt+tXk-jMxtBr3=-Y3pzZ+gLcUqgaxovtFH2QCTRu4A@mail.gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<80d2d6e6efcafd636712f8bf91c8f002d1d7692d.1426509272.git.siva.mannem.lnx@gmail.com>
	<55083D2B.4050604@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36743 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663AbbCRLgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 07:36:06 -0400
Received: by wgra20 with SMTP id a20so32603276wgr.3
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 04:36:05 -0700 (PDT)
In-Reply-To: <55083D2B.4050604@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 8:11 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 3/17/2015 2:02 AM, Siva Mannem wrote:
>
>> This patch ensures that the newly configured FDB ageing time becomes
>> effective
>> immediately. It also makes the behavior consistent when the ageing_timer
>> is set
>> using any of the three existing mechanisms(sysfs, ioctl, netlink).
>
>
>> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
>> Suggested-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>>   net/bridge/br_device.c   | 4 ++++
>>   net/bridge/br_ioctl.c    | 3 +--
>>   net/bridge/br_sysfs_br.c | 8 +-------
>>   3 files changed, 6 insertions(+), 9 deletions(-)
>
>
>> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
>> index 1a665aa..293a113 100644
>> --- a/net/bridge/br_device.c
>> +++ b/net/bridge/br_device.c
>> @@ -396,12 +396,16 @@ void br_dev_setup(struct net_device *dev)
>>   int br_set_ageing_time(struct net_bridge *br, unsigned long val)
>>   {
>>         unsigned long t = clock_t_to_jiffies(val);
>> +       unsigned long old_ageing_time;
>>
>>         if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>>                 return -ERANGE;
>>
>>         spin_lock_bh(&br->lock);
>> +       old_ageing_time =  br->ageing_time;
>
>
>    One space is enough after '='...
>
>>         br->ageing_time = t;
>> +       if (br->ageing_time < old_ageing_time)
>
>
>    Isn't it enough to compare just 't' instead of 'br->ageing_time'?
>
>> +               mod_timer(&br->gc_timer, jiffies);
>>         spin_unlock_bh(&br->lock);
>>         return 0;
>>   }
>
> [...]
>
> WBR, Sergei
>
Yep. Will address them in next version.
Thanks.

-- 
Regards,
Siva Mannem.
