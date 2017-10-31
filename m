From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Tue, 31 Oct 2017 15:09:57 -0700
Message-ID: <CAM_iQpXCHbPG0JfWLET+d7AEB5W=Rhxu6xB_kLgBjzwGq43jXg@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
 <CAM_iQpW=1kbpLxwCbBtGj3D+aVy5QseEAU+omEJUmJJwJ6P58A@mail.gmail.com>
 <CAMDBHYJTMv4MDQENNKjOXaUBHyXicOnkM_j+i7__3d1CAgdVRg@mail.gmail.com>
 <CAM_iQpUTG6hzi=kPP2t=Svoj_MHgfcs7m+_ruWVafJq26RFV8g@mail.gmail.com>
 <0dfff609-d67e-0701-399f-1dbe2ef09bf3@mojatatu.com> <CAMDBHYJ2BpzSOm3dFV98sGe5mAHrQ_z=Vmx9oUo0e6AtqbTk5w@mail.gmail.com>
 <CAMDBHYJiQWSW490syWS195vZ3iYLaczPtNt8aYdqska5q+YgHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Lucas Bates <lucasb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:43544 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753486AbdJaWKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:10:19 -0400
Received: by mail-pf0-f196.google.com with SMTP id a8so364632pfc.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 15:10:18 -0700 (PDT)
In-Reply-To: <CAMDBHYJiQWSW490syWS195vZ3iYLaczPtNt8aYdqska5q+YgHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 12:13 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
> On Tue, Oct 31, 2017 at 2:55 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
>> Unfortunately it doesn't seem to have had any effect, I'm still seeing
>> the same bug as yesterday. At Jamal's suggestion I put in a delay

As I replied to you privately, it is probably because idrinfo is freed
before action itself. So just RTNL is not enough.


>> after tdc completed running the tests but before it deleted the
>> container - and I didn't run into the bug after many runs. I had no
>> luck getting serial console access on any of our other systems so I
>> have another stack trace photo which I'll send to you directly.
>
> I forgot to mention: it appears the bug appears to be related to
> deleting the container. Test d052 is the last to run before tdc does
> its teardown and deletes the container; if I add the sleep the bug
> never gets triggered.

This almost rules out the guilty of this patchset.

I will provide a patch for you to test, since I can't reproduce it here.

Thanks!
