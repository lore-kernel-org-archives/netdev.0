From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: KASAN: use-after-free Write in detach_if_pending
Date: Mon, 30 Oct 2017 18:06:29 +0100
Message-ID: <CACT4Y+bppGVyDVCYa0eL6hG5StSCn35eqH+fjM1LOBu+ktD9rQ@mail.gmail.com>
References: <089e0825d424dfce58055c84205f@google.com> <alpine.DEB.2.20.1710291327310.1922@nanos>
 <1509282075.11887.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+YrZzmn9N5jXH-8+T9P+kbyjstDFAeNooaPdrBbzepH4w@mail.gmail.com> <1509381386.11887.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Gleixner <tglx@linutronix.de>,
        syzbot
        <bot+c0733f3aab92fc116dc1d10d8a25f5bf1f739eff@syzkaller.appspotmail.com>,
        John Stultz <john.stultz@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>, sboyd@codeaurora.org,
        syzkaller-bugs@googlegroups.com, netdev <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509381386.11887.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2017 at 5:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-10-30 at 16:48 +0100, Dmitry Vyukov wrote:
>> >
>> > net-next tree :
>> >
>> > $ git log --oneline e7989f973ae1b90ec7c0b671c81.. -- drivers/net/tun.c
>> > f8ddadc4db6c7b7029b6d0e0d9af24f74ad27ca2 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>> > ee74d9967b829232723939cb7c9b100b29f6ec98 tun: do not arm flow_gc_timer in tun_flow_init()
>> > 81d98fa4df3d1683b3ef21e8a7a0ccac7874f0de tun: avoid extra timer schedule in tun_flow_cleanup()
>> > 7dbfb4ef77db5666f0f3a425e7db93ca30ff4285 tun: do not block BH again in tun_flow_cleanup()
>> > aec72f3392b1d598a979e89c4fdb131965ae0ab3 net-tun: fix panics at dismantle time
>> > 010f245b9dd734adda6386c494a4ace953ea8dc4 tun: relax check on eth_get_headlen() return value
>> > 0ad646c81b2182f7fa67ec0c8c825e0ee165696d tun: call dev_get_valid_name() before register_netdevice()
>> > 53954cf8c5d205624167a2bfd117cc0c1a5f3c6d Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>> > 2580c4c17aee3ad58e9751012bad278dd074ccae tun: bail out from tun_get_user() if the skb is empty
>> > de8f3a83b0a0fddb2cf56e7a718127e9619ea3da bpf: add meta pointer for direct access
>> > 9484dc74fcf0750cd6726c9aa27edf97223916a8 tun: delete original tun_get() and rename __tun_get() to tun_get()
>> > 90e33d45940793def6f773b2d528e9f3c84ffdc7 tun: enable napi_gro_frags() for TUN/TAP driver
>> > 943170998b200190f99d3fe7e771437e2c51f319 tun: enable NAPI for TUN/TAP driver
>> >
>> > net tree :
>> >
>> > $ git log --oneline e7989f973ae1b90ec7c0b671c81.. -- drivers/net/tun.c
>> > 63b9ab65bd76e5de6479bb14b4014b64aa1a317a tuntap: properly align skb->head before building skb
>> > 5c25f65fd1e42685f7ccd80e0621829c105785d9 tun: allow positive return values on dev_get_valid_name() call
>> > 0ad646c81b2182f7fa67ec0c8c825e0ee165696d tun: call dev_get_valid_name() before register_netdevice()
>> > 2580c4c17aee3ad58e9751012bad278dd074ccae tun: bail out from tun_get_user() if the skb is empty
>> >
>> > Pick the fixes, they are at least 2 patches that addressed the issue.
>>
>> Let's try the last one in net-next that touches timers:
>>
>> #syz fix: tun: do not arm flow_gc_timer in tun_flow_init()
>
> Note that is is common to have multiple patches sharing a same title, so
> your tag is ambiguous.

Yes, but hashes in random trees also don't tell much. A tree can be
rebased so the hash will be lost. It can be a tree unknown to the
system. Even if we find the commit by hash, in order to match it
against other trees we will have to use the title anyway (or are there
better options?), so using hashes becomes pointless.


> Why don't you update your bot to catch up standard SHA1 title  format,
> so that we do not have to ?

Because as our internal practice shows, developers reference commits
for other reasons (a commit that introduced the bug, a commit that
should have been prevented the bug but as the report shows it does
not, a commit that may fix the bug but one does not sure, etc). It
looks reasonable for effectively a bug tracking system to explicitly
say what fixes what.
