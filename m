From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: Eliminate duplicated codes by creating
 one new function in_dev_select_addr
Date: Fri, 10 Mar 2017 09:36:19 +0800
Message-ID: <CA+6hz4rpSNn-X+T4V_ZVeWjDRMz4Bfw=vH430XqOHe0-_+V-rw@mail.gmail.com>
References: <1488898279-18930-1-git-send-email-fgao@ikuai8.com> <b2c1e98f-427f-8796-ddbe-bd4eebf6b94e@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35046 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdCJBgV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 20:36:21 -0500
Received: by mail-pg0-f68.google.com with SMTP id g2so4041774pge.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 17:36:20 -0800 (PST)
In-Reply-To: <b2c1e98f-427f-8796-ddbe-bd4eebf6b94e@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Tue, Mar 7, 2017 at 11:46 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello!
>
> On 03/07/2017 05:51 PM, fgao@ikuai8.com wrote:
>
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> There are two duplicated loop codes which used to select right
>
>
>    Just "loops".
>
>> address in current codes. Now eliminate these codes by creating
>> one new function in_dev_select_addr.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  net/ipv4/devinet.c | 34 +++++++++++++++++++---------------
>>  1 file changed, 19 insertions(+), 15 deletions(-)
>>
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index 1a9e550..d0964c5 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -1191,6 +1191,19 @@ static int inet_gifconf(struct net_device *dev,
>> char __user *buf, int len)
>>         return done;
>>  }
>>
>> +static __be32 in_dev_select_addr(const struct in_device *in_dev,
>> +                                int scope)
>> +{
>> +       for_primary_ifa(in_dev) {
>> +               if (ifa->ifa_scope != RT_SCOPE_LINK &&
>> +                   ifa->ifa_scope <= scope) {
>> +                       return ifa->ifa_local;
>> +               }
>
>
>    Could drop the useless {} here, while at it.

Thanks, I would correct it in v2 patch.

The checkpatch.pl ignores this issue when I checked this patch.
It seems one bug of checkpatch.pl

Regards
Feng

>
>> +       } endfor_ifa(in_dev);
>> +
>> +       return 0;
>> +}
>> +
>>  __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int
>> scope)
>>  {
>>         __be32 addr = 0;
>
> [...]
>
> MBR, Sergei
>
