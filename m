From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] skbuff: Fix skb checksum flag on skb pull
Date: Mon, 31 Aug 2015 20:29:02 -0700
Message-ID: <CALnjE+pri5SDS5nPyhdwgki4N-eOF0TuWWigiAhx2gCznqYOmw@mail.gmail.com>
References: <1441061746-1492-1-git-send-email-pshelar@nicira.com>
	<20150901014022.GA11983@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36454 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbIAD3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 23:29:03 -0400
Received: by igboj15 with SMTP id oj15so45499103igb.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 20:29:02 -0700 (PDT)
In-Reply-To: <20150901014022.GA11983@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2015 at 6:40 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Aug 31, 2015 at 03:55:46PM -0700, Pravin B Shelar wrote:
>> VXLAN device can receive skb with checksum partial. But the checksum
>> offset could be in outer header which is pulled on receive. Such skb
>> can cause the panic when checksum is calculated on skb. Following patch
>> fixes the bug by setting checksum unnecessary while pulling outer header.
>>
>> ---8<---
>> [ 13.800141] RIP: 0010:[<ffffffff81518034>] [<ffffffff81518034>] skb_checksum_help+0x144/0x150
>> [ 13.800141] RSP: 0000:ffff88011fd83940 EFLAGS: 00010292
>> [ 13.800141] RAX: 0000000000000042 RBX: ffff880114dd56c0 RCX: ffff8801188d9580
>> ...
>> ...
>> [ 13.852308] Call Trace:
>> [ 13.852308] <IRQ>
>> [ 13.852308] [<ffffffffa0164c28>] queue_userspace_packet+0x408/0x470 [openvswitch]
>> [ 13.852308] [<ffffffffa016614d>] ovs_dp_upcall+0x5d/0x60 [openvswitch]
>> [ 13.852308] [<ffffffffa0166236>] ovs_dp_process_packet_with_key+0xe6/0x100 [openvswitch]
>> [ 13.852308] [<ffffffffa016629b>] ovs_dp_process_received_packet+0x4b/0x80 [openvswitch]
>
> that doesn't look like upstream kernel.
> The above two functions don't exist in net-next.
>

Bug was reported on older kernel. But the issue exist on net-next
kernel. For example when vxlan checksum is turned on.
