From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH v2 net-next 1/1] driver: tun: Forbid to set IFF_TUN and
 IFF_TAP at the same time
Date: Fri, 21 Oct 2016 19:32:26 +0800
Message-ID: <CA+6hz4owMopnVPAUJgo6pRpx+KE_YdWAXXzsJ8jKNCrWuRhBTw@mail.gmail.com>
References: <1477047735-26003-1-git-send-email-fgao@ikuai8.com> <1477049287.7065.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, jasowang@redhat.com,
        edumazet@google.com, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:50840 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754814AbcJULcv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 07:32:51 -0400
Received: from mail-vk0-f44.google.com (unknown [209.85.213.44])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 19:32:27 +0800 (CST)
Received: by mail-vk0-f44.google.com with SMTP id b186so112917254vkb.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 04:32:28 -0700 (PDT)
In-Reply-To: <1477049287.7065.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Oct 21, 2016 at 7:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-10-21 at 19:02 +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> Current tun driver permits the ifr_flags is set with IFF_TUN and
>> IFF_TAP at the same time. But actually there is only IFF_TUN flag
>> works. And it does not make sense these two flags are set, so add
>> this check.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v2: Remove useless {}
>>  v1: Initial patch
>>
>>  drivers/net/tun.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 8093e39..faaa189 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1752,6 +1752,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>               if (err < 0)
>>                       return err;
>>
>> +             if ((ifr->ifr_flags & (IFF_TUN | IFF_TAP)) == (IFF_TUN | IFF_TAP))
>> +                     return -EINVAL;
>> +
>>               /* Set dev type */
>>               if (ifr->ifr_flags & IFF_TUN) {
>>                       /* TUN device */
>
>
> This might break some applications.

Yes. I consider about this case.
But I think there should be very least applications which set these
two flags at the same time.

>
> It might be too late to add this check without a grace period.
>
>
>
Yes, It needs some discussions.

Regards
Feng
