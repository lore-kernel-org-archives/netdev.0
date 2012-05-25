From: Tom Herbert <therbert@google.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Thu, 24 May 2012 23:01:07 -0700
Message-ID: <CA+mtBx-gOcfOE91LnUpdq4PqM5KQusTn5WKcq0t2xvU7XM80Pg@mail.gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<4775d023592b876909aceb152f94aa01@visp.net.lb>
	<1337540825.3361.0.camel@edumazet-glaptop>
	<ef780bd0e0b9b9e60e37fa74101f0f66@visp.net.lb>
	<1337572583.3361.8.camel@edumazet-glaptop>
	<6d7500e1c3b4b191c0b5a11003b161d6@visp.net.lb>
	<1337589005.3361.19.camel@edumazet-glaptop>
	<1337589620.3361.23.camel@edumazet-glaptop>
	<eb8cdd693530010d6736baede0cfebd8@visp.net.lb>
	<1337707497.3361.233.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44293 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2EYGBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 02:01:09 -0400
Received: by yhmm54 with SMTP id m54so339955yhm.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 23:01:08 -0700 (PDT)
In-Reply-To: <1337707497.3361.233.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think there is a potential problem in that netdev_tx_completed could
be called multiple times for the same interrupt, for example if napi
poll routine completes it's budget and is scheduled again and some new
packets are completed.  We're looking at a solution to this.

Denys, can you try to increase the netdev budget to see if that has an effect?

Thanks,
Tom

On Tue, May 22, 2012 at 10:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-05-22 at 20:11 +0300, Denys Fedoryshchenko wrote:
>
>> By the way, if BQL limit is going lower than MTU, is it considered as a
>> bug?
>> If yes, i can try to upload 3.4 to some servers and add condition to
>> WARN_ON if limit < 1500.
>
> There is no problem with BQL limit going lower than the max packet size.
>
> (With TSO it can be 64K)
>
> Remember BQL allows one packet to be sent to device, regardless of its
> size.
>
> Next packet might be blocked/stay in Qdisc
>
> If your workload is mostly idle, but sending bursts of 3 packets, then
> only one is immediately sent.
>
> Next packets shall wait the TX completion of first packet.
>
>
>
