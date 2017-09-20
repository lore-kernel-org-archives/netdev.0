From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 21:23:48 +0200
Message-ID: <548a893c-8a8f-3b07-00f7-d75de1d777ad@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
 <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
 <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
 <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
 <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
 <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
 <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
 <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
 <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com>
 <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
 <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
 <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
 <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:43146 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751650AbdITTZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 15:25:57 -0400
In-Reply-To: <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-09-20 o 21:13, Paweł Staszewski pisze:
>
>
> W dniu 2017-09-20 o 20:36, Cong Wang pisze:
>> On Wed, Sep 20, 2017 at 11:30 AM, Eric Dumazet 
>> <eric.dumazet@gmail.com> wrote:
>>> On Wed, 2017-09-20 at 11:22 -0700, Cong Wang wrote:
>>>> but dmesg at this time shows nothing about interfaces or flaps.
>>>>
>>>> This is very odd.
>>>>
>>>> We only free netdevice in free_netdev() and it is only called when
>>>> we unregister a netdevice. Otherwise pcpu_refcnt is impossible
>>>> to be NULL.
>>> If there is a missing dev_hold() or one dev_put() in excess,
>>> this would allow the netdev to be freed too soon.
>>>
>>> -> Use after free.
>>> memory holding netdev could be reallocated-cleared by some other kernel
>>> user.
>>>
>> Sure, but only unregister could trigger a free. If there is no 
>> unregister,
>> like what Pawel claims, then there is no free, the refcnt just goes to
>> 0 but the memory is still there.
>>
> About possible mistake from my side with bisect - i can judge too 
> early that some bisect was good
> the road was:
> git bisect start
> # bad: [ac7b75966c9c86426b55fe1c50ae148aa4571075] Merge tag 
> 'pinctrl-v4.13-1' of 
> git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl
> git bisect bad ac7b75966c9c86426b55fe1c50ae148aa4571075
> # good: [e24dd9ee5399747b71c1d982a484fc7601795f31] Merge branch 'next' 
> of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security
> git bisect good e24dd9ee5399747b71c1d982a484fc7601795f31
> # bad: [9cc9a5cb176ccb4f2cda5ac34da5a659926f125f] datapath: Avoid 
> using stack larger than 1024.
> git bisect bad 9cc9a5cb176ccb4f2cda5ac34da5a659926f125f
> # good: [073cf9e20c333ab29744717a23f9e43ec7512a20] Merge branch 
> 'udp-reduce-cache-pressure'
> git bisect good 073cf9e20c333ab29744717a23f9e43ec7512a20
> # bad: [8abd5599a520e9f188a750f1bde9dde5fb856230] Merge branch 
> 's390-net-updates-part-2'
> git bisect bad 8abd5599a520e9f188a750f1bde9dde5fb856230
> # good: [2fae5d0e647c6470d206e72b5fc24972bb900f70] Merge branch 
> 'bpf-ctx-narrow'
> git bisect good 2fae5d0e647c6470d206e72b5fc24972bb900f70
> # good: [41500c3e2a19ffcf40a7158fce1774de08e26ba2] rds: tcp: remove 
> cp_outgoing
> git bisect good 41500c3e2a19ffcf40a7158fce1774de08e26ba2
> # bad: [8917a777be3ba566377be05117f71b93a5fd909d] tcp: md5: add 
> TCP_MD5SIG_EXT socket option to set a key address prefix
> git bisect bad 8917a777be3ba566377be05117f71b93a5fd909d
> # good: [4a6ce2b6f2ecabbddcfe47e7cf61dd0f00b10e36] net: introduce a 
> new function dst_dev_put()
>
> And currently have this running for about 4 hours without problems.
>
>
>
> git bisect good 4a6ce2b6f2ecabbddcfe47e7cf61dd0f00b10e36
> # bad: [a4c2fd7f78915a0d7c5275e7612e7793157a01f2] net: remove 
> DST_NOCACHE flag
>
> Here for sure - panic
>
> git bisect bad a4c2fd7f78915a0d7c5275e7612e7793157a01f2
> # bad: [ad65a2f05695aced349e308193c6e2a6b1d87112] ipv6: call 
> dst_hold_safe() properly
> git bisect bad ad65a2f05695aced349e308193c6e2a6b1d87112
> # good: [9df16efadd2a8a82731dc76ff656c771e261827f] ipv4: call 
> dst_hold_safe() properly
> git bisect good 9df16efadd2a8a82731dc76ff656c771e261827f
> # bad: [1cfb71eeb12047bcdbd3e6730ffed66e810a0855] ipv6: take 
> dst->__refcnt for insertion into fib6 tree
>
> im not 100% sure tor last two
> Will test them again starting from
> [95c47f9cf5e028d1ae77dc6c767c1edc8a18025b] ipv4: call dst_dev_put() 
> properly
>
>
> git bisect bad 1cfb71eeb12047bcdbd3e6730ffed66e810a0855
> # bad: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC 
> and remove the operation of dst_free()
>
>
>
> git bisect bad b838d5e1c5b6e57b10ec8af2268824041e3ea911
> # first bad commit: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: 
> mark DST_NOGC and remove the operation of dst_free()
>
>
>
What i can say more
I can reproduce this on any server with similar configuration
the difference can be teamd instead of bonding
ixgbe or i40e and mlx5
Same problems

vlans - more or less prefixes learned from bgp -> zebra -> netlink -> kernel
But normally in lab when using only plain routing no bgpd and about 128 
vlans - with 128 routes - cant reproduce this - this apperas only with 
bgp - minimum where i can reproduce this was about 130k prefixes with 
about 286 nexthops
