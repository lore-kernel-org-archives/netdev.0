From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Thu, 9 Feb 2017 17:37:56 -0800
Message-ID: <CAM_iQpUibPgC6kW2JmkhmPneZ6p7z6QjYdAQ8ng+pxtiWJ7xVA@mail.gmail.com>
References: <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
 <20170126232912.rgh6undqxd4tofqj@dhcp-1-212.brq.redhat.com>
 <CAM_iQpXqqmAGPbo6jNJV4bOco9sfvXukNAxYPp4tfL=CNwF-RA@mail.gmail.com>
 <20170127064143.ddyt43iglu2odlld@dhcp-1-212.brq.redhat.com>
 <CAM_iQpWSRjh4sV-hQxSAFsmvXZ1P4u959vm+UfCP55szQUb0-g@mail.gmail.com>
 <20170131181411.cq3o7yxrnhq6thpt@dhcp-1-212.brq.redhat.com>
 <CAM_iQpVG+ybcv1DAc01y3c=CRmUgMqocEnp-efhVM0c-t4hZ0w@mail.gmail.com> <20170207142035.vfnyrbggb6kbfzgd@dhcp-1-212.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Mateusz Guzik <mguzik@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207142035.vfnyrbggb6kbfzgd@dhcp-1-212.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 7, 2017 at 6:20 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
>
> Yes, but unix_release_sock is expected to leave the file behind.
> Note I'm not claiming there is a leak, but that racing threads will be
> able to trigger a condition where you create a file and fail to bind it.
>

Which is expected, right? No one guarantees the success of file
creation is the success of bind, the previous code does but it is not
part of API AFAIK. Should a sane user-space application check
the file creation for a successful bind() or just check its return value?

> What to do with the file now?
>

We just do what unix_release_sock() does, so why do you keep
asking the same question?

If you still complain about the race with user-space, think about the
same race in-between a successful bind() and close(), nothing is new.
