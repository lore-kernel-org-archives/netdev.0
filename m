From: Kyle Hubert <khubert@gmail.com>
Subject: Re: Peak TCP performance
Date: Thu, 10 Oct 2013 23:33:28 -0400
Message-ID: <CAJoZ4U0tpKhknMLd7kN4uQmq-E81=EbH1Q816nX_eig=tGreAQ@mail.gmail.com>
References: <CAJoZ4U2eVUd4JiGQ6UFYMdoEwyN=MO8+9S3jGcsaYGN2vqt=3g@mail.gmail.com>
	<1381461664.4971.97.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:34020 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab3JKDd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 23:33:29 -0400
Received: by mail-qa0-f46.google.com with SMTP id j15so323700qaq.19
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 20:33:28 -0700 (PDT)
In-Reply-To: <1381461664.4971.97.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 11:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-10-10 at 22:34 -0400, Kyle Hubert wrote:
>> I'm working on a device, I consistently get 27gbps via netperf-2.6.
>> UDP reports 54gbps.
>>
>> TCP is maxed out at 100% CPU on the transmit side. On the receive
>> side, 40% of the CPU. Thus, I didn't believe I could eek anymore
>> performance out of it.
>>
>> However, very oddly, if I enabled bridged mode to forward some
>> packets, TCP performance goes up to 32gbps. The thing that bothers me
>> is that transmit CPU utilization drops to 65%, and receive CPU
>> utilization increases to 60%.
>>
>> What happens when the device becomes bridged to gain so much
>> performance? Also, can I now take advantage of the extra CPU time
>> available to drive more traffic? No tunable seems to have any effect..
>> (except down)
>
>
> You do not give what version of linux you use, but my guess is that
> using latest trees should help, because of
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c9eeec26e32e087359160406f96e0949b3cc6f10
>
> Also try to disable tx-nocache-copy
>
> ethtool -K eth0 tx-nocache-copy off

Ah, yes, sorry. I'm on 3.0.80 (SLES SP2). And, no, I do not have that
commit. In fact, the code looks quite different. There must have been
a lot of changes?

Also, my copy of ethtool does not recognize tx-nocache-copy. However,
I do have control over the net device. Is there something there I can
set, or is tx-nocache-copy also a new feature? I'll start digging.

Thanks for your response.
-Kyle
