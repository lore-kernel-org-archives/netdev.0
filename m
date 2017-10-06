From: James Chapman <jchapman@katalix.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Fri, 6 Oct 2017 10:52:44 +0100
Message-ID: <CAEwTi7RF6s1OhEEPTrDzk61QQD_AFoZ+uX-WRhc=aAVHoHJxpw@mail.gmail.com>
References: <20171001102110.24184f1b@xeon-e3> <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
 <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
 <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com> <CA++DawbbfQq1ZGB_x5t4a9mhkkptnDfcDxtCXgHYfGpY=8q83g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Guillaume Nault <g.nault@alphalink.fr>
To: SviMik <svimik@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:52699 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750989AbdJFJwt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 05:52:49 -0400
Received: from mail-pg0-f41.google.com (mail-pg0-f41.google.com [74.125.83.41])
        (Authenticated sender: james)
        by mail.katalix.com (Postfix) with ESMTPSA id 2E246A8A7D
        for <netdev@vger.kernel.org>; Fri,  6 Oct 2017 10:52:47 +0100 (BST)
Received: by mail-pg0-f41.google.com with SMTP id c137so9693478pga.11
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 02:52:47 -0700 (PDT)
In-Reply-To: <CA++DawbbfQq1ZGB_x5t4a9mhkkptnDfcDxtCXgHYfGpY=8q83g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 October 2017 at 05:45, SviMik <svimik@gmail.com> wrote:
> 2017-10-04 10:49 GMT+03:00 James Chapman <jchapman@katalix.com>:
>> On 3 October 2017 at 08:27, James Chapman <jchapman@katalix.com> wrote:
>>> For capturing complete oops messages, have you tried setting up
>>> netconsole? You might also find the full text in the syslog on reboot.
>
> Why, thank you! You've just told me that Santa Claus exists :)

You're welcome. Heh, my wife says I have a few more grey hairs and I
don't shave as often as I should. :)

> I've set up netconsole on 93 of my servers, and hope starting from
> tomorrow I'll have more pretty kernel panic reports, and get them even
> from servers where I had never had a chance to capture the console
> before.
>
>>> It's interesting that you are seeing l2tp issues since switching to
>>> 4.x kernels. Are you able to try earlier kernels to find the latest
>>> version that works? I'm curious whether things broke at v3.15.
>
> I'll try, but it will take some time to grab enough statistics. The
> bug is relatively rare, only few panics per day on the whole bunch of
> 93 servers.
>
>> It's possible that this may be fixed by a patch that is already
>> upstream and merged for v4.14. The fix is from Guillaume Nault:
>>
>> f3c66d4 l2tp: prevent creation of sessions on terminated tunnels
>>
>> If it's possible that the L2TP server may try to create a session in a
>> tunnel that is being closed, this bug would be exposed.
>>
>> Guillaume's fix isn't yet pushed to stable releases. Are you able to
>> try a v4.14-rc build?
>
> Sorry, I'm not skilled enough to build a kernel for CentOS on my own.
> Will wait till it appears in elrepo. The latest version there is
> currently 4.13.5. Meanwhile I'll try to switch to 3.10 and see how it
> works.

No problem. Please keep us updated. If Guillaume's fix in v4.14
prevents the l2tp crashes in your systems, I'd like to push it out to
stable releases. I have been trying to reproduce the problem here but
have had no luck so far. My guess is that your l2tp servers have a
large ppp population and are handling a lot of traffic. Until we have
evidence that Guillaume's patch resolves this problem, it's harder to
justify pushing it out to stable.

> I have also captured few more kernel panics in the last few days.
> Please see if they are related to this bug:
> http://svimik.com/hdmmsk1kp2.png
> http://svimik.com/hdmmsk1kp3.png
> http://svimik.com/hdmmsk1kp4.png
> http://svimik.com/hdmmsk2kp6.png

Thanks. None of these are related to this bug but it looks like p3, p4
and p6 are all in the networking code. It might be worth opening
separate threads for these. A full oops capture with netconsole would
likely get more attention though.

To check whether the oops is related to this bug yourself, please
check for text that contains "l2tp_xmit_skb" before posting it to this
thread.
