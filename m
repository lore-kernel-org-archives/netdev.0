From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 107141] New: [1177853.192071] INFO: task accel-pppd:24263
 blocked for more than 120 seconds.
Date: Wed, 11 Nov 2015 08:57:15 -0800
Message-ID: <20151111085715.337c6958@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35449 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbbKKQ5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 11:57:05 -0500
Received: by pasz6 with SMTP id z6so36880447pas.2
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 08:57:05 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id fn4sm1226686pab.46.2015.11.11.08.57.04
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 08:57:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 4 Nov 2015 10:46:56 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 107141] New: [1177853.192071] INFO: task accel-pppd:24263 blocked for more than 120 seconds.


https://bugzilla.kernel.org/show_bug.cgi?id=107141

            Bug ID: 107141
           Summary: [1177853.192071] INFO: task accel-pppd:24263 blocked
                    for more than 120 seconds.
           Product: Networking
           Version: 2.5
    Kernel Version: 4.1.12 , 4.2.0 , 4.3
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: pstaszewski@artcom.pl
        Regression: No

Latest checked kernel where no problem exist:
3.13.0



On any kernel >4.0 I have always same problem as below:

[1177853.192071] INFO: task accel-pppd:24263 blocked for more than 120 seconds.
[1177853.192074]       Not tainted 4.2.0 #1
[1177853.192075] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192076] accel-pppd      D ffff88021fc14680     0 24263      1
0x00000000
[1177853.192079]  ffff8800d6f1fd38 0000000000000082 ffff8800d6f1fde8
ffffffff81a114c0
[1177853.192081]  ffff8800d6f1fdc8 ffff880215dd2f00 ffff880215dd2f00
ffff8800d6f20000
[1177853.192082]  ffff880215dd2f00 ffffffff81a91324 ffffffff81a91328
00000000ffffffff
[1177853.192084] Call Trace:
[1177853.192090]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192092]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192094]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192096]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192098]  [<ffffffff8141b7be>] ppp_ioctl+0x4a/0xb9d
[1177853.192102]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
[1177853.192104]  [<ffffffff815d0da9>] ? _raw_spin_lock+0x9/0xb
[1177853.192107]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192108]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
[1177853.192110]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192111] INFO: task accel-pppd:17877 blocked for more than 120 seconds.
[1177853.192112]       Not tainted 4.2.0 #1
[1177853.192113] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192114] accel-pppd      D ffff88021fd14680     0 17877      1
0x00000000
[1177853.192116]  ffff8800d75ebb68 0000000000000082 ffff8800d75ebb48
ffff8802161c0000
[1177853.192117]  ffff880215912000 ffff880215c2c680 ffff88009a4c7000
ffff8800d75ec000
[1177853.192119]  ffff880215c2c680 ffffffff81a9d264 ffffffff81a9d268
00000000ffffffff
[1177853.192120] Call Trace:
[1177853.192122]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192124]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192126]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192129]  [<ffffffff814ea475>] ?
rht_key_hashfn.isra.18.constprop.53+0x18/0x24
[1177853.192130]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192133]  [<ffffffff814ca63c>] rtnl_lock+0x10/0x12
[1177853.192134]  [<ffffffff814ca66c>] rtnetlink_rcv+0x11/0x28
[1177853.192136]  [<ffffffff814ec76d>] netlink_unicast+0x104/0x186
[1177853.192137]  [<ffffffff814eca77>] netlink_sendmsg+0x288/0x2d9
[1177853.192139]  [<ffffffff814a9d99>] sock_sendmsg_nosec+0x12/0x1d
[1177853.192141]  [<ffffffff814aaed9>] ___sys_sendmsg+0x192/0x217
[1177853.192144]  [<ffffffff810e8e50>] ? do_wp_page+0x1de/0x324
[1177853.192146]  [<ffffffff8114225a>] ?
hrtimer_start_expires.constprop.10+0x16/0x18
[1177853.192147]  [<ffffffff81142722>] ? timerfd_read+0x209/0x232
[1177853.192149]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192151]  [<ffffffff8112513d>] ? __fget_light+0x3c/0x48
[1177853.192153]  [<ffffffff814ab29e>] __sys_sendmsg+0x3d/0x5b
[1177853.192155]  [<ffffffff814ab2c9>] SyS_sendmsg+0xd/0x19
[1177853.192156]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192157] INFO: task accel-pppd:19818 blocked for more than 120 seconds.
[1177853.192158]       Not tainted 4.2.0 #1
[1177853.192159] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192159] accel-pppd      D ffff88021fd14680     0 19818      1
0x00000000
[1177853.192161]  ffff880215acfb68 0000000000000082 ffff880215acfb98
ffff8802161c0000
[1177853.192163]  ffff880215acfb68 ffff8800d8339780 ffff88009a4c7400
ffff880215ad0000
[1177853.192164]  ffff8800d8339780 ffffffff81a9d264 ffffffff81a9d268
00000000ffffffff
[1177853.192165] Call Trace:
[1177853.192167]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192169]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192170]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192172]  [<ffffffff814ea475>] ?
rht_key_hashfn.isra.18.constprop.53+0x18/0x24
[1177853.192174]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192175]  [<ffffffff814ca63c>] rtnl_lock+0x10/0x12
[1177853.192177]  [<ffffffff814ca66c>] rtnetlink_rcv+0x11/0x28
[1177853.192178]  [<ffffffff814ec76d>] netlink_unicast+0x104/0x186
[1177853.192179]  [<ffffffff814eca77>] netlink_sendmsg+0x288/0x2d9
[1177853.192181]  [<ffffffff814a9d99>] sock_sendmsg_nosec+0x12/0x1d
[1177853.192182]  [<ffffffff814aaed9>] ___sys_sendmsg+0x192/0x217
[1177853.192184]  [<ffffffff810e8e50>] ? do_wp_page+0x1de/0x324
[1177853.192185]  [<ffffffff8114225a>] ?
hrtimer_start_expires.constprop.10+0x16/0x18
[1177853.192187]  [<ffffffff81142722>] ? timerfd_read+0x209/0x232
[1177853.192188]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192190]  [<ffffffff8112513d>] ? __fget_light+0x3c/0x48
[1177853.192192]  [<ffffffff814ab29e>] __sys_sendmsg+0x3d/0x5b
[1177853.192193]  [<ffffffff814ab2c9>] SyS_sendmsg+0xd/0x19
[1177853.192194]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192196] INFO: task accel-pppd:10821 blocked for more than 120 seconds.
[1177853.192196]       Not tainted 4.2.0 #1
[1177853.192197] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192198] accel-pppd      D ffff88021fd14680     0 10821      1
0x00000000
[1177853.192199]  ffff8800d771fd08 0000000000000082 ffff8800d771fcd8
ffff8802161c0000
[1177853.192201]  ffff8800d7720000 ffff8801fe650bc0 ffff8800d771fce8
ffff8800d7720000
[1177853.192202]  ffff8801fe650bc0 ffffffff81a9d264 ffffffff81a9d268
00000000ffffffff
[1177853.192203] Call Trace:
[1177853.192205]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192207]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192208]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192210]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192212]  [<ffffffff814ca63c>] rtnl_lock+0x10/0x12
[1177853.192214]  [<ffffffff814c14b2>] register_netdev+0x11/0x27
[1177853.192215]  [<ffffffff8141ba62>] ppp_ioctl+0x2ee/0xb9d
[1177853.192218]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
[1177853.192219]  [<ffffffff815d0da9>] ? _raw_spin_lock+0x9/0xb
[1177853.192221]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192222]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
[1177853.192224]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192225] INFO: task accel-pppd:24274 blocked for more than 120 seconds.
[1177853.192226]       Not tainted 4.2.0 #1
[1177853.192226] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192227] accel-pppd      D ffff88021fc14680     0 24274      1
0x00000000
[1177853.192228]  ffff88020cfa7d38 0000000000000082 ffff88020cfa7de8
ffffffff81a114c0
[1177853.192230]  ffff88020cfa7dc8 ffff88021390af00 0000000000000292
ffff88020cfa8000
[1177853.192231]  ffff88021390af00 ffffffff81a91324 ffffffff81a91328
00000000ffffffff
[1177853.192233] Call Trace:
[1177853.192234]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192236]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192238]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192239]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192241]  [<ffffffff8141b7be>] ppp_ioctl+0x4a/0xb9d
[1177853.192243]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
[1177853.192244]  [<ffffffff815d0da9>] ? _raw_spin_lock+0x9/0xb
[1177853.192246]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192247]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
[1177853.192248]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192250] INFO: task accel-pppd:28232 blocked for more than 120 seconds.
[1177853.192250]       Not tainted 4.2.0 #1
[1177853.192251] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192252] accel-pppd      D ffff88021fc94680     0 28232      1
0x00000000
[1177853.192253]  ffff880213ba3cb8 0000000000000082 ffff880213ba3c98
ffff8802161769c0
[1177853.192254]  00000000ffffffff ffff88020cf31780 0000000000000001
ffff880213ba4000
[1177853.192256]  ffff88020cf31780 ffffffff81a9d264 ffffffff81a9d268
00000000ffffffff
[1177853.192257] Call Trace:
[1177853.192259]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192260]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192262]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192264]  [<ffffffff81116ece>] ? full_name_hash+0x19/0x63
[1177853.192265]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192267]  [<ffffffff814ca63c>] rtnl_lock+0x10/0x12
[1177853.192269]  [<ffffffff8154c918>] devinet_ioctl+0x108/0x552
[1177853.192271]  [<ffffffff814bb4a6>] ? dev_get_by_name_rcu+0x34/0x56
[1177853.192272]  [<ffffffff814d1126>] ? dev_ioctl+0x455/0x59b
[1177853.192274]  [<ffffffff8154da2a>] inet_ioctl+0x87/0xa4
[1177853.192275]  [<ffffffff814a8bad>] sock_do_ioctl+0x21/0x40
[1177853.192277]  [<ffffffff814a8fc8>] sock_ioctl+0x1ee/0x1fd
[1177853.192278]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
[1177853.192280]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192281]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
[1177853.192282]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192284] INFO: task accel-pppd:2299 blocked for more than 120 seconds.
[1177853.192284]       Not tainted 4.2.0 #1
[1177853.192285] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192286] accel-pppd      D ffff88021fd94680     0  2299      1
0x00000000
[1177853.192287]  ffff88021394fd38 0000000000000082 ffff88021394fd08
ffff8802161c0bc0
[1177853.192289]  ffff88021394fdc0 ffff88020cf30bc0 ffff88021394fd38
ffff880213950000
[1177853.192290]  ffff88020cf30bc0 ffffffff81a91324 ffffffff81a91328
00000000ffffffff
[1177853.192291] Call Trace:
[1177853.192293]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192295]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192296]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192298]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192299]  [<ffffffff8141bca5>] ppp_ioctl+0x531/0xb9d
[1177853.192301]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
[1177853.192303]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177853.192304]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
[1177853.192305]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177853.192306] INFO: task accel-pppd:6838 blocked for more than 120 seconds.
[1177853.192307]       Not tainted 4.2.0 #1
[1177853.192308] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177853.192308] accel-pppd      D ffff88021fc14680     0  6838      1
0x00000000
[1177853.192310]  ffff8800c5ca7d08 0000000000000082 00000000000380ef
ffffffff81a114c0
[1177853.192311]  000000000f48ff3a ffff8800d76c3ac0 0000000000000000
ffff8800c5ca8000
[1177853.192313]  ffff8800d76c3ac0 ffff880215e3cdac ffff880215e3cdb0
00000000ffffffff
[1177853.192314] Call Trace:
[1177853.192316]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177853.192317]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177853.192319]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177853.192320]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177853.192322]  [<ffffffff8141ab77>] ppp_dev_uninit+0x62/0xae
[1177853.192324]  [<ffffffff814bd4e2>] rollback_registered_many+0x19e/0x252
[1177853.192325]  [<ffffffff814bd600>] rollback_registered+0x29/0x38
[1177853.192327]  [<ffffffff814bd679>] unregister_netdevice_queue+0x6a/0x77
[1177853.192328]  [<ffffffff8141b740>] ppp_release+0x3f/0x73
[1177853.192330]  [<ffffffff81110a49>] __fput+0xdf/0x184
[1177853.192332]  [<ffffffff81110b1e>] ____fput+0x9/0xb
[1177853.192335]  [<ffffffff8104fac7>] task_work_run+0x7b/0x94
[1177853.192336]  [<ffffffff81003615>] do_notify_resume+0x40/0x44
[1177853.192338]  [<ffffffff815d1182>] int_signal+0x12/0x17
[1177973.074845] INFO: task accel-pppd:24263 blocked for more than 120 seconds.
[1177973.074848]       Not tainted 4.2.0 #1
[1177973.074849] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177973.074850] accel-pppd      D ffff88021fc14680     0 24263      1
0x00000000
[1177973.074853]  ffff8800d6f1fd38 0000000000000082 ffff8800d6f1fde8
ffffffff81a114c0
[1177973.074855]  ffff8800d6f1fdc8 ffff880215dd2f00 ffff880215dd2f00
ffff8800d6f20000
[1177973.074857]  ffff880215dd2f00 ffffffff81a91324 ffffffff81a91328
00000000ffffffff
[1177973.074859] Call Trace:
[1177973.074865]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177973.074867]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177973.074869]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177973.074870]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177973.074873]  [<ffffffff8141b7be>] ppp_ioctl+0x4a/0xb9d
[1177973.074877]  [<ffffffff8111d8de>] do_vfs_ioctl+0x418/0x460
[1177973.074879]  [<ffffffff815d0da9>] ? _raw_spin_lock+0x9/0xb
[1177973.074882]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177973.074883]  [<ffffffff8111d974>] SyS_ioctl+0x4e/0x7e
[1177973.074885]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a
[1177973.074886] INFO: task accel-pppd:17877 blocked for more than 120 seconds.
[1177973.074887]       Not tainted 4.2.0 #1
[1177973.074888] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[1177973.074889] accel-pppd      D ffff88021fd14680     0 17877      1
0x00000000
[1177973.074890]  ffff8800d75ebb68 0000000000000082 ffff8800d75ebb48
ffff8802161c0000
[1177973.074892]  ffff880215912000 ffff880215c2c680 ffff88009a4c7000
ffff8800d75ec000
[1177973.074893]  ffff880215c2c680 ffffffff81a9d264 ffffffff81a9d268
00000000ffffffff
[1177973.074895] Call Trace:
[1177973.074896]  [<ffffffff815ceb86>] schedule+0x71/0x80
[1177973.074898]  [<ffffffff815cecbc>] schedule_preempt_disabled+0x9/0xb
[1177973.074900]  [<ffffffff815cf918>] __mutex_lock_slowpath+0xa6/0x104
[1177973.074903]  [<ffffffff814ea475>] ?
rht_key_hashfn.isra.18.constprop.53+0x18/0x24
[1177973.074905]  [<ffffffff815cf989>] mutex_lock+0x13/0x24
[1177973.074907]  [<ffffffff814ca63c>] rtnl_lock+0x10/0x12
[1177973.074909]  [<ffffffff814ca66c>] rtnetlink_rcv+0x11/0x28
[1177973.074910]  [<ffffffff814ec76d>] netlink_unicast+0x104/0x186
[1177973.074912]  [<ffffffff814eca77>] netlink_sendmsg+0x288/0x2d9
[1177973.074914]  [<ffffffff814a9d99>] sock_sendmsg_nosec+0x12/0x1d
[1177973.074915]  [<ffffffff814aaed9>] ___sys_sendmsg+0x192/0x217
[1177973.074918]  [<ffffffff810e8e50>] ? do_wp_page+0x1de/0x324
[1177973.074920]  [<ffffffff8114225a>] ?
hrtimer_start_expires.constprop.10+0x16/0x18
[1177973.074922]  [<ffffffff81142722>] ? timerfd_read+0x209/0x232
[1177973.074924]  [<ffffffff811250c2>] ? __fget+0x2a/0x69
[1177973.074926]  [<ffffffff8112513d>] ? __fget_light+0x3c/0x48
[1177973.074927]  [<ffffffff814ab29e>] __sys_sendmsg+0x3d/0x5b
[1177973.074929]  [<ffffffff814ab2c9>] SyS_sendmsg+0xd/0x19
[1177973.074930]  [<ffffffff815d0fd7>] entry_SYSCALL_64_fastpath+0x12/0x6a

-- 
You are receiving this mail because:
You are the assignee for the bug.
