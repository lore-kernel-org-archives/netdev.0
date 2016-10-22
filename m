From: Andrey Vagin <avagin@openvz.org>
Subject: Re: [PATCH] net: skip genenerating uevents for network namespaces
 that are exiting
Date: Sat, 22 Oct 2016 00:37:01 -0700
Message-ID: <CANaxB-wvJsts7RUEg1pouD0xMLTQAoVMaWaXZ2wLFT9XE1E1Mw@mail.gmail.com>
References: <1477017986-18889-1-git-send-email-avagin@openvz.org>
 <CAM_iQpVA=W3su_a3OUVSD+19A72TMANnCX4dt9UyLOmVoRuBjQ@mail.gmail.com> <CANaxB-zo4YW7o-Ebe08B_L_f8Wyp6tMWc-rBRt8-4sSc1Y=tgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANaxB-zo4YW7o-Ebe08B_L_f8Wyp6tMWc-rBRt8-4sSc1Y=tgg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cong,

On Thu, Oct 20, 2016 at 10:25 PM, Andrey Vagin <avagin@openvz.org> wrote:
> On Thu, Oct 20, 2016 at 8:10 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Oct 20, 2016 at 7:46 PM, Andrei Vagin <avagin@openvz.org> wrote:
>>> No one can see these events, because a network namespace can not be
>>> destroyed, if it has sockets.
>>>
>>
>> Are you sure? kobject_uevent_env() seems sending uevents to all
>> network namespaces.
>
> kobj_bcast_filter() checks that a kobject namespace is equal to a
> socket namespace.

Today I've checked that it really works as I read from the source code.
I use this tool to read events:
https://gist.github.com/avagin/430ba431fc2972002df40ebe6a048b36

And I see that events from non-network devices are delivered to all sockets,
but events from network devices are delivered only to sockets from
a network namespace where a device is operated.

Thanks,
Andrei

>
>
>> _______________________________________________
>> Containers mailing list
>> Containers@lists.linux-foundation.org
>> https://lists.linuxfoundation.org/mailman/listinfo/containers
