From: "Zdenek Kabelac" <zdenek.kabelac@gmail.com>
Subject: Re: INFO: possible recursive locking detected dev_deactivate
Date: Wed, 30 Jul 2008 12:01:37 +0200
Message-ID: <c4e36d110807300301n344aa27ei8740f1a5a72c2112@mail.gmail.com>
References: <c4e36d110807290453h7381adb8l8b8785f434e968ac@mail.gmail.com>
	 <20080730024724.519f0662.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.158]:16082 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbYG3KBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 06:01:38 -0400
Received: by po-out-1718.google.com with SMTP id c31so424720poi.1
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 03:01:37 -0700 (PDT)
In-Reply-To: <20080730024724.519f0662.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/7/30 Andrew Morton <akpm@linux-foundation.org>:
>
> (cc's added)
>
> On Tue, 29 Jul 2008 13:53:39 +0200 "Zdenek Kabelac" <zdenek.kabelac@gmail.com> wrote:
>
>> Hi
>>
>> With kernel from yesterdays' git (08/07/28) (sorry I've already
>> deleted any traces for more precise commit number) - I've just found
>> the bactrace in the log running already today's 2.6.27-rc1.
>>
>> Happened during the reboot of 2.6.26
>> As usually T61, 2GB, C2D
>>
>> =============================================
>> [ INFO: possible recursive locking detected ]
>> 2.6.26 #47

Update - happens with 2.6.27-rc1 (commit:
6e86841d05f371b5b9b86ce76c02aaee83352298)

Zdenek














>> ---------------------------------------------
>> NetworkManager/2623 is trying to acquire lock:
>>  (_xmit_IEEE80211#2){-...}, at: [<ffffffff812a3cd2>] dev_deactivate+0x82/0x150
>>
>> but task is already holding lock:
>>  (_xmit_IEEE80211#2){-...}, at: [<ffffffff812a3cd2>] dev_deactivate+0x82/0x150
>>
>> other info that might help us debug this:
>> 2 locks held by NetworkManager/2623:
>>  #0:  (rtnl_mutex){--..}, at: [<ffffffff8129ca0a>] rtnetlink_rcv+0x1a/0x40
>>  #1:  (_xmit_IEEE80211#2){-...}, at: [<ffffffff812a3cd2>]
>> dev_deactivate+0x82/0x150
>>
>> stack backtrace:
>> Pid: 2623, comm: NetworkManager Not tainted 2.6.26 #47
>>
>> Call Trace:
>>  [<ffffffff81068b4a>] __lock_acquire+0xcea/0x13b0
>>  [<ffffffff810674fd>] ? mark_held_locks+0x4d/0x90
>>  [<ffffffff810657a4>] ? get_lock_stats+0x34/0x70
>>  [<ffffffff812a3cd2>] ? dev_deactivate+0x82/0x150
>>  [<ffffffff810692a6>] lock_acquire+0x96/0xe0
>>  [<ffffffff812a3cd2>] ? dev_deactivate+0x82/0x150
>>  [<ffffffff81315161>] _spin_lock+0x31/0x60
>>  [<ffffffff812a3cd2>] dev_deactivate+0x82/0x150
>>  [<ffffffff81292885>] dev_close+0x65/0xc0
>>  [<ffffffffa013a9d9>] ieee80211_stop+0x339/0x4e0 [mac80211]
>>  [<ffffffff81292896>] dev_close+0x76/0xc0
>>  [<ffffffff81292461>] dev_change_flags+0xa1/0x1e0
>>  [<ffffffff8129b774>] do_setlink+0x214/0x3a0
>>  [<ffffffff81318c60>] ? sub_preempt_count+0x80/0x120
>>  [<ffffffff81314e40>] ? _read_unlock+0x30/0x60
>>  [<ffffffff8129bacd>] rtnl_setlink+0x10d/0x150
>>  [<ffffffff8129cbbd>] rtnetlink_rcv_msg+0x18d/0x240
>>  [<ffffffff8129ca30>] ? rtnetlink_rcv_msg+0x0/0x240
>>  [<ffffffff812a77e9>] netlink_rcv_skb+0x89/0xb0
>>  [<ffffffff8129ca19>] rtnetlink_rcv+0x29/0x40
>>  [<ffffffff812a720d>] netlink_unicast+0x2cd/0x2e0
>>  [<ffffffff8128b01e>] ? __alloc_skb+0x6e/0x150
>>  [<ffffffff812a7424>] netlink_sendmsg+0x204/0x300
>>  [<ffffffff81314e5e>] ? _read_unlock+0x4e/0x60
>>  [<ffffffff812827d7>] sock_sendmsg+0x127/0x140
>>  [<ffffffff81057120>] ? autoremove_wake_function+0x0/0x40
>>  [<ffffffff810677ad>] ? trace_hardirqs_on+0xd/0x10
>>  [<ffffffff8106773b>] ? trace_hardirqs_on_caller+0x14b/0x1b0
>>  [<ffffffff812835f7>] ? move_addr_to_kernel+0x57/0x60
>>  [<ffffffff8128c04f>] ? verify_iovec+0x3f/0xe0
>>  [<ffffffff81282979>] sys_sendmsg+0x189/0x320
>>  [<ffffffff812836fd>] ? sys_sendto+0xfd/0x120
>>  [<ffffffff810e1a8c>] ? d_free+0x6c/0x80
>>  [<ffffffff810cec01>] ? __fput+0x171/0x1c0
>>  [<ffffffff8106773b>] ? trace_hardirqs_on_caller+0x14b/0x1b0
>>  [<ffffffff813148d6>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>>  [<ffffffff8100c5bb>] system_call_fastpath+0x16/0x1b
>>
>> iwl3945 0000:03:00.0: PCI INT A disabled
>
>
