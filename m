From: SviMik <svimik@gmail.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Mon, 2 Oct 2017 21:35:09 +0300
Message-ID: <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
References: <20171001102110.24184f1b@xeon-e3> <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:52172 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdJBSfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:35:10 -0400
Received: by mail-ua0-f173.google.com with SMTP id 47so3489409uas.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 11:35:10 -0700 (PDT)
In-Reply-To: <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, James!

No, I'm suffering from kernel panics since I started using 4.x
kernels. See my current collection:
http://svimik.com/hdmmsk1kp1.png
http://svimik.com/hdmmsk2kp2.png
http://svimik.com/hdmmsk2kp3.png
http://svimik.com/hdmmsk2kp4.png
http://svimik.com/hdmmsk2kp5.png
http://svimik.com/hdmmsk7kp1.png

Screenshots are from three different machines, kernels from 4.8.13 to 4.13.4.

2017-10-02 16:56 GMT+03:00 Eric Dumazet <eric.dumazet@gmail.com>:
> CC svimik@gmail.com so that he is aware of this netdev thread.
>
> On Mon, 2017-10-02 at 14:32 +0100, James Chapman wrote:
>> This seems to be a NULL pointer exception caused by tunnel->sock being
>> NULL at the call to bh_lock_sock() in l2tp_xmit_skb() at
>> l2tp_core.c:1135.
>>
>> tunnel->sock is set NULL in l2tp_core's tunnel socket destructor.
>>
>> At the moment, I don't understand how this happens because
>> pppol2tp_xmit() does a sock_hold() on the tunnel socket before
>> l2tp_xmit_skb() is called. I'm still looking at this.
>>
>> Has this problem only recently started happening?
>>
>>
>>
>>
>>
>> On 1 October 2017 at 18:21, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>> >
>> >
>> > Begin forwarded message:
>> >
>> > Date: Sun, 01 Oct 2017 16:22:33 +0000
>> > From: bugzilla-daemon@bugzilla.kernel.org
>> > To: stephen@networkplumber.org
>> > Subject: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
>> >
>> >
>> > https://bugzilla.kernel.org/show_bug.cgi?id=197099
>> >
>> >             Bug ID: 197099
>> >            Summary: Kernel panic in interrupt [l2tp_ppp]
>> >            Product: Networking
>> >            Version: 2.5
>> >     Kernel Version: 4.8.13-1.el6.elrepo.x86_64
>> >           Hardware: x86-64
>> >                 OS: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: normal
>> >           Priority: P1
>> >          Component: Other
>> >           Assignee: stephen@networkplumber.org
>> >           Reporter: svimik@gmail.com
>> >         Regression: No
>> >
>> > Created attachment 258685
>> >   --> https://bugzilla.kernel.org/attachment.cgi?id=258685&action=edit
>> > stacktrace screenshot
>> >
>> > Hello!
>> >
>> > Getting kernel panics on multiple servers. Since it mentions l2tp_core,
>> > l2tp_ppp and ppp_generic, I decided to report it to Networking (correct me if
>> > I'm wrong).
>> >
>> > Unfortunately I'm still struggling with making kdump work, so the trace
>> > screenshot is all I have at this moment. The only hope is that this stacktrace
>> > means something to the guys that wrote the code.
>> >
>> > --
>> > You are receiving this mail because:
>> > You are the assignee for the bug.
>
>
