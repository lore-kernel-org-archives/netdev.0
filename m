From: SviMik <svimik@gmail.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Sat, 7 Oct 2017 15:09:48 +0300
Message-ID: <CA++DawbMB8aFa3s-0jW2CC5pRTU2Ui4ec6GSRCkhMotGGj_Ytg@mail.gmail.com>
References: <20171001102110.24184f1b@xeon-e3> <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
 <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
 <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
 <CA++DawbbfQq1ZGB_x5t4a9mhkkptnDfcDxtCXgHYfGpY=8q83g@mail.gmail.com> <CAEwTi7RF6s1OhEEPTrDzk61QQD_AFoZ+uX-WRhc=aAVHoHJxpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Guillaume Nault <g.nault@alphalink.fr>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:45032 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdJGMJt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 08:09:49 -0400
Received: by mail-vk0-f49.google.com with SMTP id d12so10881000vkf.1
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 05:09:48 -0700 (PDT)
In-Reply-To: <CAEwTi7RF6s1OhEEPTrDzk61QQD_AFoZ+uX-WRhc=aAVHoHJxpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-10-06 12:52 GMT+03:00 James Chapman <jchapman@katalix.com>:
> On 6 October 2017 at 05:45, SviMik <svimik@gmail.com> wrote:
>> 2017-10-04 10:49 GMT+03:00 James Chapman <jchapman@katalix.com>:
>>> On 3 October 2017 at 08:27, James Chapman <jchapman@katalix.com> wrote:
>>>> For capturing complete oops messages, have you tried setting up
>>>> netconsole? You might also find the full text in the syslog on reboot.
>>
>> Why, thank you! You've just told me that Santa Claus exists :)
>
> You're welcome. Heh, my wife says I have a few more grey hairs and I
> don't shave as often as I should. :)
>
>> I've set up netconsole on 93 of my servers, and hope starting from
>> tomorrow I'll have more pretty kernel panic reports, and get them even
>> from servers where I had never had a chance to capture the console
>> before.

Unfortunately, netconsole has managed to send a kernel panic trace
only once, and it's not related to this bug. Looks like something
crashes really hard to make netconsole unusable.

Just for record, it seems to me that tun_do_read() has some bug too:
http://svimik.com/hdmmsk1kp5.txt
Shall I report it to a separate thread?

Meanwhile, I have found that kdump in CentOS just fails to work with
kernels >=4.9 while working fine with 4.8.
It says:
Rebuilding /boot/initrd-4.9.48-29.el6.x86_64kdump.img
No module ext4 found for kernel 4.9.48-29.el6.x86_64, aborting.
Failed to run mkdumprd

>>>> It's interesting that you are seeing l2tp issues since switching to
>>>> 4.x kernels. Are you able to try earlier kernels to find the latest
>>>> version that works? I'm curious whether things broke at v3.15.
>>
>> I'll try, but it will take some time to grab enough statistics. The
>> bug is relatively rare, only few panics per day on the whole bunch of
>> 93 servers.

I have tested the kernel 3.10.107-1.el6.elrepo.x86_64 for 24 hours,
and have to say that none of kernel panics occurred on any of the
servers during this period. Which is pretty impressive comparing how
many different oops I had with 4.x kernels. Oops which were not
related to this bug are gone too.
