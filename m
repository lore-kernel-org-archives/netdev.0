From: Yuchung Cheng <ycheng@google.com>
Subject: Re: RACK not getting disabled
Date: Mon, 18 Sep 2017 14:46:18 -0700
Message-ID: <CAK6E8=eu+1ywBfpAM34seZDKVc-ep5HBuz9fQRuzoaX9BWqeJA@mail.gmail.com>
References: <20170918201428.GB28186@strugglingcoder.info> <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170918212952.GC28186@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: hiren panchasara <hiren@strugglingcoder.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:54061 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdIRVrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:47:00 -0400
Received: by mail-wr0-f173.google.com with SMTP id l22so1608637wrc.10
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:46:59 -0700 (PDT)
In-Reply-To: <20170918212952.GC28186@strugglingcoder.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 2:29 PM, hiren panchasara
<hiren@strugglingcoder.info> wrote:
> On 09/18/17 at 02:18P, Eric Dumazet wrote:
>> On Mon, 2017-09-18 at 13:14 -0700, hiren panchasara wrote:
>> > Hi all, I am trying to disable rack to see 3dupacks in action during
>> > loss-detection but based on the pcap, I see that it's still trigger
>> > loss-recovery on the first SACK (as if RACK is still enabled/active).
just to be clear: 3-dupack (aka RFC3517) is still enabled with RACK
enabled. I am experimenting a patch set to disable 3-dupack approach
completely.

>> >
>> > Here is what I did to disable rack:
>> > net.ipv4.tcp_recovery = 0
>> >
>> > I've also disabled metrics:
>> > net.ipv4.tcp_no_metrics_save = 1
>> > And also flushed existing entries with 'ip tcp_metrics flush' just to be
>> > on a safer side.
>> >
>> > Not really relevant here but I've also switched to reno.
>> >
>> > I am on: 4.10.0-33-generic
>> > pcap: https://transfer.sh/mfoiN/reno_no_rack.pcap
>> >
>> > What am I missing? I can provide any additional info.
>> >
>> > Cheers,
>> > Hiren
>>
>>
>> A single SACK can contains enough information to trigger a retransmit.
>
> Bah, right. FACK!
>>
>> If you absolutely want to see the old 3 dupack in action, you also want
>> to disable SACK.
>
> I believe net.ipv4.tcp_fack = 0 would achieve that without disabling
> sack.
>
> Thanks for your help!
> Cheers,
> Hiren
