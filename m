From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics codes
 of veth driver
Date: Thu, 3 Nov 2016 22:38:28 +0800
Message-ID: <CA+6hz4owi2WgeGWd98=8d=Q5DBPY4_ZtYAOgcM1V_0+OU8UHrw@mail.gmail.com>
References: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
 <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com> <1478183516.7065.440.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:53500 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751691AbcKCOiu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 10:38:50 -0400
Received: from mail-ua0-f177.google.com (unknown [209.85.217.177])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 22:38:29 +0800 (CST)
Received: by mail-ua0-f177.google.com with SMTP id 51so40838733uai.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 07:38:30 -0700 (PDT)
In-Reply-To: <1478183516.7065.440.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 3, 2016 at 10:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-11-03 at 21:39 +0800, Gao Feng wrote:
>> Hi Eric,
>>
>> On Thu, Nov 3, 2016 at 9:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2016-11-03 at 21:03 +0800, fgao@ikuai8.com wrote:
>> >> From: Gao Feng <fgao@ikuai8.com>
>> >>
>> >> The dropped count of veth is located in struct veth_priv, but other
>> >> statistics like packets and bytes are in another struct pcpu_vstats.
>> >> Now keep these three counters in the same struct.
>> >>
>> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> >> ---
>> >>  v2: Use right "peer" instead of "dev";
>> >>  v1: Initial version
>> >
>> > May I ask : Why ?
>>
>> Just because I think statistics should be in the same struct.
>
> That is not a good reason then.

Because other net devices put the statistics together.
Take tun/tap as example, it is a virtual device, but its all
statistics are percpu including dropped.

Regards
Feng

>
>>
>> >
>> > We did that because there was no point making per-cpu requirements
>> > bigger, for a counter that is hardly ever updated.
>> >
>> > Do you have a real case where performance dropping packets in a driver
>> > is needed ?
>>
>> No, I haven't met the performance issue now.
>
> OK then kill this patch.
>
>>
>> >
>> > At some point we will have to stop dumb percpu explosion, when we have
>> > 128+ cores per host. Folding all these percpu counters is taking a lot
>> > of time too.
>> >
>> >
>> >
>> Ok, I get it. It is designed specially to put the dropped counter as
>> atomic counter, not percpu.
>> But I have one question that when put the counters as percpu, and when not?
>
> Because the regular fast path needs to be fast ?
>
> Try to _use_ veth without these percpu stats and be prepared to be
> shocked.
>
>
>
