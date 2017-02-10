From: Jason Wang <jasowang@redhat.com>
Subject: Re: net: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in
 skb_array_produce
Date: Fri, 10 Feb 2017 13:13:55 +0800
Message-ID: <2ccb37fe-44f2-4d78-3cf7-bb1676a1016b@redhat.com>
References: <CACT4Y+bs15VR7xjeYhece+0_X5Ss+5FM0w6jpJH0Dbbdu-+qCQ@mail.gmail.com>
 <50038580.20299907.1486634551103.JavaMail.zimbra@redhat.com>
 <CACT4Y+ZVS_SvUarbvk4aeXkJvFCCfgozq5DzHYLcfbjMN4aTtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZVS_SvUarbvk4aeXkJvFCCfgozq5DzHYLcfbjMN4aTtg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年02月09日 18:49, Dmitry Vyukov wrote:
> On Thu, Feb 9, 2017 at 11:02 AM, Jason Wang<jasowang@redhat.com>  wrote:
>> ----- Original Message -----
>>> Hello,
>>>
>>> I've got the following report while running syzkaller fuzzer on mmotm
>>> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
>>> remotes/mmotm/auto-latest ee4ba7533626ba7bf2f8b992266467ac9fdc045e:
>>>
>> [...]
>>
>>> other info that might help us debug this:
>>>
>>>   Possible interrupt unsafe locking scenario:
>>>
>>>         CPU0                    CPU1
>>>         ----                    ----
>>>    lock(&(&r->consumer_lock)->rlock);
>>>                                 local_irq_disable();
>>>                                 lock(&(&r->producer_lock)->rlock);
>>>                                 lock(&(&r->consumer_lock)->rlock);
>>>    <Interrupt>
>>>      lock(&(&r->producer_lock)->rlock);
>>>
>> Thanks a lot for the testing.
>>
>> Looks like we could address this by using skb_array_consume_bh() instead.
>>
>> Could you pls verify if the following patch works?
> No, I can't test it, sorry. This happened once on bots. And bots
> currently test only upstream versions.
>
>

No problem, will try to test my self.

Thanks
