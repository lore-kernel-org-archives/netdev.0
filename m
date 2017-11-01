From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Wed, 1 Nov 2017 12:55:45 -0400
Message-ID: <CAMDBHYLdQHXzbEiZdh+Y_NeY8ipE1zE4HHZ9NhN24G7v5PFE4w@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
 <CAM_iQpW=1kbpLxwCbBtGj3D+aVy5QseEAU+omEJUmJJwJ6P58A@mail.gmail.com>
 <CAMDBHYJTMv4MDQENNKjOXaUBHyXicOnkM_j+i7__3d1CAgdVRg@mail.gmail.com>
 <CAM_iQpUTG6hzi=kPP2t=Svoj_MHgfcs7m+_ruWVafJq26RFV8g@mail.gmail.com>
 <0dfff609-d67e-0701-399f-1dbe2ef09bf3@mojatatu.com> <CAMDBHYJ2BpzSOm3dFV98sGe5mAHrQ_z=Vmx9oUo0e6AtqbTk5w@mail.gmail.com>
 <CAMDBHYJiQWSW490syWS195vZ3iYLaczPtNt8aYdqska5q+YgHQ@mail.gmail.com>
 <CAM_iQpXCHbPG0JfWLET+d7AEB5W=Rhxu6xB_kLgBjzwGq43jXg@mail.gmail.com> <CAM_iQpV+4_ae++398_Jrr4W=u_Ep=g9SXfGs5O-=_2ZkyosYgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:49733 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754773AbdKAQ4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:56:07 -0400
Received: by mail-wm0-f50.google.com with SMTP id b189so5914053wmd.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 09:56:07 -0700 (PDT)
In-Reply-To: <CAM_iQpV+4_ae++398_Jrr4W=u_Ep=g9SXfGs5O-=_2ZkyosYgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 7:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Oct 31, 2017 at 3:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> This almost rules out the guilty of this patchset.
>>
>> I will provide a patch for you to test, since I can't reproduce it here.
>>
>
> Lucas, please test the attached patch, it applies to latest -net.
>
> Note, it is a combination of 3 patches which together close the
> use-after-free you reported here, I hope.
>
> Please let me know if this works. My basic tests run well without
> any stack traces or memory leaks.

The results look good to me.

I compiled with the patch and ran the test again in a loop. I set it
to run 50 times in a row and didn't trigger the bug once (previous
record was 4 times).
