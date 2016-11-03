From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics codes
 of veth driver
Date: Thu, 3 Nov 2016 21:39:11 +0800
Message-ID: <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com>
References: <1478178237-23020-1-git-send-email-fgao@ikuai8.com> <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau1.qq.com ([54.206.16.166]:58592 "EHLO smtpbgau1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755005AbcKCNjb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:39:31 -0400
Received: from mail-vk0-f51.google.com (unknown [209.85.213.51])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 21:39:12 +0800 (CST)
Received: by mail-vk0-f51.google.com with SMTP id x186so39697020vkd.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:39:13 -0700 (PDT)
In-Reply-To: <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Nov 3, 2016 at 9:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-11-03 at 21:03 +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> The dropped count of veth is located in struct veth_priv, but other
>> statistics like packets and bytes are in another struct pcpu_vstats.
>> Now keep these three counters in the same struct.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v2: Use right "peer" instead of "dev";
>>  v1: Initial version
>
> May I ask : Why ?

Just because I think statistics should be in the same struct.

>
> We did that because there was no point making per-cpu requirements
> bigger, for a counter that is hardly ever updated.
>
> Do you have a real case where performance dropping packets in a driver
> is needed ?

No, I haven't met the performance issue now.

>
> At some point we will have to stop dumb percpu explosion, when we have
> 128+ cores per host. Folding all these percpu counters is taking a lot
> of time too.
>
>
>
Ok, I get it. It is designed specially to put the dropped counter as
atomic counter, not percpu.
But I have one question that when put the counters as percpu, and when not?

Regards
Feng
